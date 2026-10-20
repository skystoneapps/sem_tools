import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/ui/number_format.dart';
import '../../heat_transfer/ui/heat_palette.dart';
import '../../l10n/app_localizations.dart';
import '../domain/expansion_model.dart';

/// Draws the liquid volume in two states side by side:
/// 1. Cold (initial) state at density ρ₁, occupying volume V₀ with mass
///    m = ρ₁·V₀.
/// 2. Heated (expanded) state at lower density ρ₂, where the same mass m
///    occupies a larger volume V₂ = V₀ + ΔV.
class VesselPainter extends CustomPainter {
  VesselPainter({
    required this.result,
    required this.palette,
    required this.colorScheme,
    required this.l10n,
    required this.textStyle,
  });

  final ExpansionResult result;
  final HeatPalette palette;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final inputs = result.inputs;
    final valid = result.densityValid;

    final coldColor = temperatureColor(15);
    final hotColor = temperatureColor(90);

    const topSpace = 50.0;
    const bottomSpace = 36.0;
    final availH = math.max(80.0, size.height - topSpace - bottomSpace);
    final vesselH = math.min(availH, 164.0);
    final vesselW = math.min(vesselH * 0.68, (size.width - 100) * 0.30).clamp(
      64.0,
      116.0,
    );

    final vesselTop = topSpace + (availH - vesselH) / 2;
    final vesselBottom = vesselTop + vesselH;

    // Base fill for V₀; the top band represents the expansion ΔV.
    const baseFill = 0.68;
    final relExpansion = valid && result.initialVolume > 0
        ? (result.expansionVolume / result.initialVolume).clamp(0.0, 1.0)
        : 0.0;
    // Exaggerate small percentage expansions visually so ΔV is clearly visible.
    final deltaFill = valid && relExpansion > 0
        ? (0.16 + relExpansion * 0.6).clamp(0.16, 0.26)
        : 0.0;

    final leftCx = size.width * 0.24;
    final rightCx = size.width * 0.76;

    // --- Left: Cold state ---------------------------------------------------
    _drawHeader(
      canvas,
      centerX: leftCx,
      title: l10n.vesselColdState,
      subtitle: 'ρ₁ = ${fmtInput(inputs.densityCold)} kg/m³',
    );
    _drawVessel(
      canvas,
      cx: leftCx,
      top: vesselTop,
      width: vesselW,
      height: vesselH,
      liquidColor: coldColor,
      baseFill: baseFill,
      deltaFill: 0,
      baseLabel: 'V₀ = ${fmtValue(result.initialLitres)} L',
      deltaLabel: null,
      footerLabel: 'm = ${fmtValue(result.mass)} kg',
    );

    // --- Center transition arrow --------------------------------------------
    final midX = (leftCx + rightCx) / 2;
    final midY = (vesselTop + vesselBottom) / 2;
    final arrowHalf = math.min(
      32.0,
      (rightCx - leftCx - vesselW - 20) / 2,
    );
    if (arrowHalf > 8) {
      final arrowColor = colorScheme.primary;
      _drawHorizontalArrow(
        canvas,
        Offset(midX - arrowHalf, midY),
        Offset(midX + arrowHalf, midY),
        arrowColor,
      );
      _drawText(
        canvas,
        l10n.vesselConstantMass,
        Offset(midX, midY - 20),
        textStyle.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: palette.mutedText,
        ),
        align: TextAlign.center,
      );
      if (valid) {
        _drawText(
          canvas,
          '+${fmtValue(result.expansionLitres)} L',
          Offset(midX, midY + 8),
          textStyle.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: hotColor,
          ),
          align: TextAlign.center,
        );
      }
    }

    // --- Right: Heated state ------------------------------------------------
    _drawHeader(
      canvas,
      centerX: rightCx,
      title: l10n.vesselHeatedState,
      subtitle: 'ρ₂ = ${fmtInput(inputs.densityHot)} kg/m³',
    );
    _drawVessel(
      canvas,
      cx: rightCx,
      top: vesselTop,
      width: vesselW,
      height: vesselH,
      liquidColor: hotColor,
      baseFill: baseFill,
      deltaFill: deltaFill,
      baseLabel: 'V₀',
      deltaLabel: valid ? 'ΔV = ${fmtValue(result.expansionLitres)} L' : null,
      footerLabel: 'V₂ = ${fmtValue(result.finalLitres)} L',
    );
  }

  void _drawHeader(
    Canvas canvas, {
    required double centerX,
    required String title,
    required String subtitle,
  }) {
    _drawText(
      canvas,
      title,
      Offset(centerX, 6),
      textStyle.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: palette.text,
      ),
      align: TextAlign.center,
    );
    _drawText(
      canvas,
      subtitle,
      Offset(centerX, 24),
      textStyle.copyWith(fontSize: 11, color: palette.mutedText),
      align: TextAlign.center,
    );
  }

  void _drawVessel(
    Canvas canvas, {
    required double cx,
    required double top,
    required double width,
    required double height,
    required Color liquidColor,
    required double baseFill,
    required double deltaFill,
    required String baseLabel,
    required String? deltaLabel,
    required String footerLabel,
  }) {
    final bottom = top + height;
    final radius = Radius.circular(width * 0.28);
    final vesselRect = Rect.fromLTWH(cx - width / 2, top, width, height);
    final vesselRRect = RRect.fromRectAndRadius(vesselRect, radius);

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = palette.outline;

    canvas.save();
    canvas.clipRRect(vesselRRect);

    // Empty head space at the top of the vessel.
    canvas.drawRect(
      vesselRect,
      Paint()..color = colorScheme.surfaceContainerHighest,
    );

    final v0Top = bottom - height * baseFill;
    final totalTop = bottom - height * (baseFill + deltaFill);

    // Total liquid column.
    final liquidRect = Rect.fromLTRB(
      vesselRect.left,
      totalTop,
      vesselRect.right,
      bottom,
    );
    canvas.drawRect(
      liquidRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(liquidColor, Colors.white, 0.22)!,
            liquidColor,
          ],
        ).createShader(liquidRect),
    );

    // Highlight the expansion band ΔV above V₀.
    if (deltaFill > 0) {
      final deltaRect = Rect.fromLTRB(
        vesselRect.left,
        totalTop,
        vesselRect.right,
        v0Top,
      );
      canvas.drawRect(
        deltaRect,
        Paint()..color = Colors.white.withValues(alpha: 0.14),
      );
      _drawDashedLine(
        canvas,
        Offset(vesselRect.left, v0Top),
        Offset(vesselRect.right, v0Top),
        Colors.white.withValues(alpha: 0.85),
      );
    }

    canvas.restore();
    canvas.drawRRect(vesselRRect, outlinePaint);

    const onLiquidShadow = [Shadow(blurRadius: 3, color: Colors.black54)];

    if (deltaLabel != null && deltaFill > 0) {
      final deltaCy = (totalTop + v0Top) / 2;
      _drawText(
        canvas,
        deltaLabel,
        Offset(cx, deltaCy - 7),
        textStyle.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: onLiquidShadow,
        ),
        align: TextAlign.center,
      );
    }

    final baseCy = (v0Top + bottom) / 2;
    _drawText(
      canvas,
      baseLabel,
      Offset(cx, baseCy - 7),
      textStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        shadows: onLiquidShadow,
      ),
      align: TextAlign.center,
    );

    _drawText(
      canvas,
      footerLabel,
      Offset(cx, bottom + 8),
      textStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: palette.text,
      ),
      align: TextAlign.center,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color;
    const dash = 5.0;
    const gap = 4.0;
    var x = from.dx;
    while (x < to.dx) {
      final end = math.min(x + dash, to.dx);
      canvas.drawLine(Offset(x, from.dy), Offset(end, from.dy), paint);
      x += dash + gap;
    }
  }

  void _drawHorizontalArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Color color,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawLine(from, to.translate(-6, 0), paint);
    const head = 7.0;
    canvas.drawPath(
      Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(to.dx - head, to.dy - head * 0.6)
        ..lineTo(to.dx - head, to.dy + head * 0.6)
        ..close(),
      Paint()..color = color,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style, {
    TextAlign align = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      TextAlign.center => -painter.width / 2,
      TextAlign.right => -painter.width,
      _ => 0.0,
    };
    painter.paint(canvas, position.translate(dx, 0));
  }

  @override
  bool shouldRepaint(VesselPainter oldDelegate) =>
      oldDelegate.result.inputs != result.inputs ||
      oldDelegate.palette != palette ||
      oldDelegate.colorScheme != colorScheme ||
      oldDelegate.l10n != l10n ||
      oldDelegate.textStyle != textStyle;
}
