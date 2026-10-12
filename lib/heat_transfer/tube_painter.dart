import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'formula_text.dart';
import 'heat_model.dart';
import 'heat_palette.dart';

/// Draws a cut-away view of the insulated tube: the bare pipe with a window
/// into the flowing fluid on the left, the insulated section with its
/// cross-section end face on the right, and heat arrows for every stage.
/// The [highlighted] stage is outlined. [animation] runs from 0 to 1 repeatedly and drives the flow.
class TubePainter extends CustomPainter {
  TubePainter({
    required this.result,
    required this.palette,
    required this.l10n,
    required this.textStyle,
    required this.highlighted,
    required this.animation,
  }) : super(repaint: animation);

  final HeatTransferResult result;
  final HeatPalette palette;
  final AppLocalizations l10n;
  final TextStyle textStyle;
  final HeatStage? highlighted;
  final Animation<double> animation;

  static const _topSpace = 92.0;
  static const _bottomSpace = 72.0;

  @override
  void paint(Canvas canvas, Size size) {
    final inputs = result.inputs;
    final t = animation.value;

    final avail = math.max(40.0, size.height - _topSpace - _bottomSpace);
    final r = math.min(avail / 2, size.width * 0.16);
    final cy = _topSpace + avail / 2;
    final e = r * 0.34;
    final xLeft = 16 + e;
    final xRight = size.width - 16 - e;
    final xCut = xLeft + (xRight - xLeft) * 0.26;

    // Visual radius fractions, clamped so every layer stays visible.
    final f1 = (inputs.r1 / inputs.r3).clamp(0.28, 0.86);
    final f2 = math.max(inputs.r2 / inputs.r3, f1 + 0.07).clamp(0.0, 0.95);
    final pipeR = r * f2;
    final fluidR = r * f1;
    final fluidColor = temperatureColor(result.fluidTemp);

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.outline;

    // --- Bare pipe with a cut-away window into the fluid -------------------
    final pipeBody = Path.combine(
      PathOperation.union,
      Path()..addRect(Rect.fromLTRB(xLeft, cy - pipeR, xCut, cy + pipeR)),
      Path()..addOval(_ellipse(Offset(xLeft, cy), e * f2, pipeR)),
    );
    canvas.drawPath(
      pipeBody,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.metalDark,
            palette.metalLight,
            palette.metalMid,
            palette.metalDark,
          ],
          stops: const [0, 0.3, 0.65, 1],
        ).createShader(Rect.fromLTRB(0, cy - pipeR, size.width, cy + pipeR)),
    );
    canvas.drawPath(pipeBody, outlinePaint);

    final window = RRect.fromRectAndRadius(
      Rect.fromLTRB(xLeft + 10, cy - fluidR, xCut - 8, cy + fluidR),
      const Radius.circular(3),
    );
    if (window.width > 20) {
      canvas.drawRRect(
        window,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(fluidColor, Colors.white, 0.35)!,
              fluidColor,
              Color.lerp(fluidColor, Colors.black, 0.25)!,
            ],
          ).createShader(window.outerRect),
      );
      _drawFlowChevrons(canvas, window, t);
      canvas.drawRRect(window, outlinePaint);
    }

    // --- Insulated section ---------------------------------------------------
    final insulationBody = Path.combine(
      PathOperation.union,
      Path()..addRect(Rect.fromLTRB(xCut, cy - r, xRight, cy + r)),
      Path()..addOval(_ellipse(Offset(xCut, cy), e, r)),
    );
    canvas.drawPath(
      insulationBody,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.insulationDark,
            palette.insulationLight,
            palette.insulationFace,
            palette.insulationDark,
          ],
          stops: const [0, 0.28, 0.6, 1],
        ).createShader(Rect.fromLTRB(0, cy - r, size.width, cy + r)),
    );
    canvas.drawPath(insulationBody, outlinePaint);

    // Cladding straps.
    final strapPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = palette.metalMid.withValues(alpha: 0.8);
    for (final fraction in const [0.3, 0.74]) {
      final x = xCut + (xRight - xCut) * fraction;
      canvas.drawArc(
        _ellipse(Offset(x, cy), e, r),
        -math.pi / 2,
        math.pi,
        false,
        strapPaint,
      );
    }

    // --- Cross-section end face ---------------------------------------------
    final face = Offset(xRight, cy);
    canvas.drawOval(
      _ellipse(face, e, r),
      Paint()..color = palette.insulationFace,
    );
    canvas.drawOval(_ellipse(face, e, r), outlinePaint);
    canvas.drawOval(
      _ellipse(face, e * f2, pipeR),
      Paint()..color = palette.metalMid,
    );
    canvas.drawOval(_ellipse(face, e * f2, pipeR), outlinePaint);
    canvas.drawOval(
      _ellipse(face, e * f1, fluidR),
      Paint()
        ..shader = RadialGradient(
          colors: [Color.lerp(fluidColor, Colors.white, 0.3)!, fluidColor],
        ).createShader(_ellipse(face, e * f1, fluidR)),
    );
    canvas.drawOval(_ellipse(face, e * f1, fluidR), outlinePaint);

    // --- Heat path arrows ------------------------------------------------------
    final inward = result.heatRate < 0;
    final hasFlow = result.heatRate.abs() > 1e-9;

    if (hasFlow) {
      _arrow(
        canvas,
        Offset(xRight, cy - fluidR * 0.15),
        Offset(xRight, cy - fluidR + 3),
        palette.convection,
        inward: inward,
        bold: highlighted == HeatStage.innerConvection,
      );
      if (pipeR - fluidR > 12) {
        _arrow(
          canvas,
          Offset(xRight, cy - fluidR - 1),
          Offset(xRight, cy - pipeR + 1),
          palette.conduction,
          inward: inward,
          bold: highlighted == HeatStage.pipeConduction,
        );
      }
      for (final dir in const [-1.0, 1.0]) {
        _arrow(
          canvas,
          Offset(xRight, cy + dir * (pipeR + 3)),
          Offset(xRight, cy + dir * (r - 3)),
          palette.conduction,
          inward: inward,
          bold: highlighted == HeatStage.insulationConduction,
        );
      }
      _drawSurfaceArrows(canvas, xCut + e + 14, xRight - e, cy - r, t, inward);
    }

    // --- Highlight of the selected stage -------------------------------------
    final stage = highlighted;
    if (stage != null) {
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = palette.mechanism(stage.mechanism);
      switch (stage) {
        case HeatStage.innerConvection:
          if (window.width > 20) canvas.drawRRect(window, glow);
          canvas.drawOval(_ellipse(face, e * f1, fluidR), glow);
        case HeatStage.pipeConduction:
          canvas.drawPath(pipeBody, glow);
          canvas.drawOval(_ellipse(face, e * f2, pipeR), glow);
        case HeatStage.insulationConduction:
          canvas.drawPath(insulationBody, glow);
          canvas.drawOval(_ellipse(face, e, r), glow);
        case HeatStage.outerConvection:
        case HeatStage.outerRadiation:
          canvas.drawLine(Offset(xCut, cy - r), Offset(xRight, cy - r), glow);
      }
    }

    // --- Labels ---------------------------------------------------------------
    final ambient = _layout(
      '${l10n.tubeAmbient}   T∞ = ${_celsius(result.ambientTemp)}',
      textStyle.copyWith(color: palette.mutedText),
    );
    ambient.paint(canvas, const Offset(8, 6));
    _drawLegend(canvas, size, ambient.width + 8);

    final surfaceCenter = Offset(xCut + (xRight - xCut) * 0.52, cy);
    final onIns = textStyle.copyWith(color: palette.onInsulation);
    _text(
      canvas,
      l10n.tubeOuterSurface,
      surfaceCenter.translate(0, -16),
      onIns.copyWith(fontSize: 11),
      align: TextAlign.center,
    );
    _text(
      canvas,
      _celsius(result.surfaceTemp),
      surfaceCenter.translate(0, 0),
      onIns.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
      align: TextAlign.center,
    );

    _drawLayerLabels(canvas, size, face, e, r, f1, f2);
  }

  void _drawFlowChevrons(Canvas canvas, RRect window, double t) {
    canvas.save();
    canvas.clipRRect(window);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.75);
    const spacing = 22.0;
    final h = math.min(window.height * 0.28, 7.0);
    final cy = window.center.dy;
    for (
      var x = window.left - spacing + t * spacing;
      x < window.right + spacing;
      x += spacing
    ) {
      canvas.drawPath(
        Path()
          ..moveTo(x - h * 0.6, cy - h)
          ..lineTo(x + h * 0.4, cy)
          ..lineTo(x - h * 0.6, cy + h),
        paint,
      );
    }
    canvas.restore();
  }

  void _drawSurfaceArrows(
    Canvas canvas,
    double from,
    double to,
    double surfaceY,
    double t,
    bool inward,
  ) {
    final kinds = [
      result[HeatStage.outerConvection],
      result[HeatStage.outerRadiation],
    ];
    if (to - from < 20) return;

    final count = math.max(kinds.length, ((to - from) / 46).floor());
    final total = result.heatRate.abs();
    for (var i = 0; i < count; i++) {
      final stage = kinds[i % kinds.length];
      final x = count == 1
          ? (from + to) / 2
          : from + (to - from) * i / (count - 1);
      final share = total == 0 ? 0.0 : (stage.heatRate.abs() / total);
      final color = palette
          .mechanism(stage.stage.mechanism)
          .withValues(alpha: 0.35 + 0.65 * share.clamp(0.0, 1.0));
      final bold = highlighted == stage.stage;
      final start = Offset(x, surfaceY - 5);
      if (stage.stage == HeatStage.outerConvection) {
        _wavyArrow(
          canvas,
          start,
          Offset(x + 4, surfaceY - 58),
          color,
          amplitude: 5,
          wavelength: 24,
          phase: t,
          inward: inward,
          bold: bold,
        );
      } else {
        final lean = (i.isEven ? -1 : 1) * 14.0;
        _wavyArrow(
          canvas,
          start,
          Offset(x + lean, surfaceY - 56),
          color,
          amplitude: 3.5,
          wavelength: 9,
          phase: t * 2,
          inward: inward,
          bold: bold,
        );
      }
    }
  }

  /// Heat leaving the surface per mechanism, top right. Drops to a second
  /// line when it would run into the ambient label ending at [minX].
  void _drawLegend(Canvas canvas, Size size, double minX) {
    final style = textStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w600);
    final painters = [
      for (final stage in [HeatStage.outerRadiation, HeatStage.outerConvection])
        _layout(
          '${stage == HeatStage.outerConvection ? l10n.mechanismConvection : l10n.mechanismRadiation}'
          '  ${fmt(result[stage].heatRate, 3)} W',
          style.copyWith(color: palette.mechanism(stage.mechanism)),
        ),
    ];
    const gap = 16.0;
    final width = painters.fold(0.0, (sum, p) => sum + p.width + gap) - gap;
    final y = size.width - 8 - width < minX + gap ? 24.0 : 6.0;
    var x = size.width - 8;
    for (final painter in painters) {
      x -= painter.width;
      painter.paint(canvas, Offset(x, y));
      x -= gap;
    }
  }

  void _drawLayerLabels(
    Canvas canvas,
    Size size,
    Offset face,
    double e,
    double r,
    double f1,
    double f2,
  ) {
    final inputs = result.inputs;
    final title = textStyle.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: palette.text,
    );
    final detail = textStyle.copyWith(fontSize: 11, color: palette.mutedText);
    final labels = [
      (
        l10n.tubeInsulation,
        'k = ${fmtInput(inputs.kInsulation)} W/m·K',
        (f2 + 1) / 2,
        HeatStage.insulationConduction,
      ),
      (
        l10n.tubePipeWall,
        'k = ${fmtInput(inputs.kPipe)} W/m·K',
        (f1 + f2) / 2,
        HeatStage.pipeConduction,
      ),
      (
        l10n.tubeFluid,
        'T = ${_celsius(result.fluidTemp)}',
        f1 * 0.45,
        HeatStage.innerConvection,
      ),
    ];

    const angle = 70 * math.pi / 180;
    final labelTop = size.height - 32;
    var right = size.width - 8;
    for (final (name, info, fraction, stage) in labels) {
      final titlePainter = _layout(name, title);
      final infoPainter = _layout(info, detail);
      final width = math.max(titlePainter.width, infoPainter.width);
      final left = right - width;
      titlePainter.paint(canvas, Offset(left, labelTop));
      infoPainter.paint(canvas, Offset(left, labelTop + 15));

      final anchor = face.translate(
        e * fraction * math.cos(angle),
        r * fraction * math.sin(angle),
      );
      final active = highlighted == stage;
      final leaderColor = active
          ? palette.mechanism(stage.mechanism)
          : palette.mutedText.withValues(alpha: 0.7);
      final leader = Paint()
        ..color = leaderColor
        ..strokeWidth = active ? 1.6 : 1;
      canvas.drawLine(Offset(left + width / 2, labelTop - 4), anchor, leader);
      canvas.drawCircle(anchor, 2.5, Paint()..color = leaderColor);
      right = left - 22;
    }
  }

  void _arrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color, {
    required bool inward,
    required bool bold,
  }) {
    _wavyArrow(
      canvas,
      from,
      to,
      color,
      amplitude: 0,
      wavelength: 1,
      phase: 0,
      inward: inward,
      bold: bold,
    );
  }

  void _wavyArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color, {
    required double amplitude,
    required double wavelength,
    required double phase,
    required bool inward,
    required bool bold,
  }) {
    if (inward) (from, to) = (to, from);
    final delta = to - from;
    final length = delta.distance;
    if (length < 6) return;
    final dir = delta / length;
    final normal = Offset(-dir.dy, dir.dx);
    final bodyLength = length - 6;

    final path = Path();
    const steps = 48;
    for (var i = 0; i <= steps; i++) {
      final s = bodyLength * i / steps;
      final taper = math.sin(math.pi * i / steps);
      final offset =
          amplitude * taper * math.sin(2 * math.pi * (s / wavelength - phase));
      final p = from + dir * s + normal * offset;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = bold ? 2.8 : 1.8
        ..strokeCap = StrokeCap.round
        ..color = color,
    );

    final head = bold ? 9.0 : 7.0;
    final base = to - dir * head;
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(
          (base + normal * head * 0.55).dx,
          (base + normal * head * 0.55).dy,
        )
        ..lineTo(
          (base - normal * head * 0.55).dx,
          (base - normal * head * 0.55).dy,
        )
        ..close(),
      Paint()..color = color,
    );
  }

  TextPainter _layout(String text, TextStyle style) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _text(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style, {
    TextAlign align = TextAlign.left,
  }) {
    final painter = _layout(text, style);
    final dx = switch (align) {
      TextAlign.center => -painter.width / 2,
      TextAlign.right => -painter.width,
      _ => 0.0,
    };
    painter.paint(canvas, position.translate(dx, 0));
  }

  static String _celsius(double value) => '${fmtTemp(value)} °C';

  static Rect _ellipse(Offset center, double rx, double ry) =>
      Rect.fromCenter(center: center, width: 2 * rx, height: 2 * ry);

  @override
  bool shouldRepaint(TubePainter oldDelegate) =>
      oldDelegate.result != result ||
      oldDelegate.highlighted != highlighted ||
      oldDelegate.palette != palette ||
      oldDelegate.l10n != l10n ||
      oldDelegate.textStyle != textStyle;
}
