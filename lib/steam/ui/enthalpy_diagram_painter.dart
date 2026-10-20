import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../common/ui/number_format.dart';
import '../../heat_transfer/ui/heat_palette.dart';
import '../../l10n/app_localizations.dart';
import '../domain/steam_model.dart';

/// Stage colours for the 3-stage steam process, per brightness.
Color steamStageColor(SteamStage stage, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return switch (stage) {
    SteamStage.liquidHeating =>
      dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
    SteamStage.evaporation =>
      dark ? const Color(0xFFFB923C) : const Color(0xFFD97706),
    SteamStage.superheating =>
      dark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
  };
}

/// Icon for each stage of steam generation.
IconData steamStageIcon(SteamStage stage) => switch (stage) {
  SteamStage.liquidHeating => Icons.water_drop_outlined,
  SteamStage.evaporation => Icons.bubble_chart_outlined,
  SteamStage.superheating => Icons.whatshot_outlined,
};

/// Key thermodynamic state points along the isobaric heating path.
enum DiagramStatePoint {
  /// Initial subcooled liquid state (T₁, h₁).
  startLiquid,

  /// Saturated liquid state where boiling starts (T_sat, h_f).
  saturatedLiquid,

  /// Dry saturated steam state where boiling finishes (T_sat, h_g).
  saturatedSteam,

  /// Final superheated steam state (T₂, h₂).
  endSteam,
}

/// Target currently hovered on the T–h diagram: either a state point or a
/// heating stage (q₁, q₂, q₃).
sealed class DiagramHoverTarget {
  const DiagramHoverTarget();
}

class DiagramHoverPoint extends DiagramHoverTarget {
  const DiagramHoverPoint(this.point);

  final DiagramStatePoint point;

  @override
  bool operator ==(Object other) =>
      other is DiagramHoverPoint && other.point == point;

  @override
  int get hashCode => point.hashCode;
}

class DiagramHoverStage extends DiagramHoverTarget {
  const DiagramHoverStage(this.stage);

  final SteamStage stage;

  @override
  bool operator ==(Object other) =>
      other is DiagramHoverStage && other.stage == stage;

  @override
  int get hashCode => stage.hashCode;
}

/// Shared coordinate mapping and hit-testing geometry for the T–h diagram.
class EnthalpyDiagramLayout {
  EnthalpyDiagramLayout({required this.size, required this.result}) {
    const leftPad = 54.0;
    const rightPad = 24.0;
    const topPad = 28.0;
    const bottomPad = 62.0;

    final plotLeft = leftPad;
    final plotRight = math.max(plotLeft + 80, size.width - rightPad);
    final plotTop = topPad;
    final plotBottom = math.max(plotTop + 80, size.height - bottomPad);
    plotRect = Rect.fromLTRB(plotLeft, plotTop, plotRight, plotBottom);

    final t1 = result.stages[0].tStart;
    final tSat = result.tSat;
    final t2 = result.stages[2].tEnd;

    hMin = 0.0;
    hMax = math.max(3200.0, result.h2 * 1.08);

    tMin = math.min(0.0, t1 - 10.0);
    tMax = math.max(
      math.max(t2, tSat) + 45.0,
      waterCriticalTempCelsius + 25.0,
    );
  }

  final Size size;
  final SteamResult result;

  late final Rect plotRect;
  late final double hMin;
  late final double hMax;
  late final double tMin;
  late final double tMax;

  double xOfH(double h) =>
      plotRect.left +
      ((h - hMin) / (hMax - hMin)).clamp(0.0, 1.0) * plotRect.width;

  double yOfT(double t) =>
      plotRect.bottom -
      ((t - tMin) / (tMax - tMin)).clamp(0.0, 1.0) * plotRect.height;

  /// Screen position of a [DiagramStatePoint].
  Offset pointOffset(DiagramStatePoint point) => switch (point) {
    DiagramStatePoint.startLiquid => Offset(
      xOfH(result.h1),
      yOfT(result.stages[0].tStart),
    ),
    DiagramStatePoint.saturatedLiquid => Offset(
      xOfH(result.hf),
      yOfT(result.tSat),
    ),
    DiagramStatePoint.saturatedSteam => Offset(
      xOfH(result.hg),
      yOfT(result.tSat),
    ),
    DiagramStatePoint.endSteam => Offset(
      xOfH(result.h2),
      yOfT(result.stages[2].tEnd),
    ),
  };

  /// Active state points for the current result.
  List<DiagramStatePoint> get activePoints => [
    DiagramStatePoint.startLiquid,
    DiagramStatePoint.saturatedLiquid,
    DiagramStatePoint.saturatedSteam,
    if (result.isSuperheated) DiagramStatePoint.endSteam,
  ];

  /// Visual rectangle of the bottom enthalpy bar for [stage].
  Rect stageBarRect(SteamStage stage) {
    final s = result[stage];
    const barHeight = 20.0;
    final x0 = xOfH(s.hStart);
    final x1 = xOfH(s.hEnd);
    final rawWidth = x1 - x0;
    // Ensure even very small non-zero stages render a visible pill (≥ 6 px).
    if (s.specificHeat > 0 && rawWidth < 6.0) {
      final cx = (x0 + x1) / 2;
      return Rect.fromLTRB(
        cx - 3.0,
        plotRect.bottom + 4,
        cx + 3.0,
        plotRect.bottom + 4 + barHeight,
      );
    }
    return Rect.fromLTRB(
      x0,
      plotRect.bottom + 4,
      x1,
      plotRect.bottom + 4 + barHeight,
    );
  }

  /// Anchor position (in canvas coordinates) for positioning a tooltip above
  /// or near the [target].
  Offset anchorFor(DiagramHoverTarget target) => switch (target) {
    DiagramHoverPoint(:final point) => pointOffset(point),
    DiagramHoverStage(:final stage) => () {
      final s = result[stage];
      final midH = (s.hStart + s.hEnd) / 2;
      final midT = (s.tStart + s.tEnd) / 2;
      return Offset(xOfH(midH), yOfT(midT));
    }(),
  };

  /// Hit-tests [pos] against state points first, then bottom q₁/q₂/q₃ bars,
  /// then the isobaric curve segments and shaded areas.
  DiagramHoverTarget? hitTest(Offset pos) {
    // 1. State points (highest priority so endpoints/phase-change points are
    // easy to inspect even where segments meet).
    DiagramStatePoint? closestPoint;
    var bestPointDist = 16.0;
    for (final pt in activePoints) {
      final d = (pos - pointOffset(pt)).distance;
      if (d <= bestPointDist) {
        bestPointDist = d;
        closestPoint = pt;
      }
    }
    if (closestPoint != null) {
      return DiagramHoverPoint(closestPoint);
    }

    final activeStages = [
      for (final s in result.stages)
        if (s.specificHeat > 0 || s.stage != SteamStage.superheating) s,
    ];

    // 2. Bottom stage bars (q₁, q₂, q₃), expanded horizontally to ≥ 22 px so
    // short phases are easy to hover.
    if (pos.dy >= plotRect.bottom && pos.dy <= plotRect.bottom + 30) {
      SteamStage? matchedStage;
      var bestCenterDist = double.infinity;
      for (final s in activeStages) {
        final rect = stageBarRect(s.stage);
        final minWidth = math.max(rect.width, 22.0);
        final hitRect = Rect.fromCenter(
          center: rect.center,
          width: minWidth,
          height: 28.0,
        );
        if (hitRect.contains(pos)) {
          final dist = (pos.dx - rect.center.dx).abs();
          if (dist < bestCenterDist) {
            bestCenterDist = dist;
            matchedStage = s.stage;
          }
        }
      }
      if (matchedStage != null) {
        return DiagramHoverStage(matchedStage);
      }
    }

    // 3. Isobaric line segments (within 12 px, even when a phase is steep or short).
    SteamStage? closestSegment;
    var bestSegDist = 12.0;
    for (final s in activeStages) {
      final p0 = Offset(xOfH(s.hStart), yOfT(s.tStart));
      final p1 = Offset(xOfH(s.hEnd), yOfT(s.tEnd));
      final d = _distanceToSegment(pos, p0, p1);
      if (d <= bestSegDist) {
        bestSegDist = d;
        closestSegment = s.stage;
      }
    }
    if (closestSegment != null) {
      return DiagramHoverStage(closestSegment);
    }

    // 4. Shaded enthalpy bands beneath the curve inside the plot area.
    if (plotRect.contains(pos)) {
      for (final s in activeStages) {
        final x0 = xOfH(s.hStart);
        final x1 = xOfH(s.hEnd);
        if (pos.dx >= x0 && pos.dx <= x1) {
          final y0 = yOfT(s.tStart);
          final y1 = yOfT(s.tEnd);
          final frac = (x1 - x0).abs() < 1e-6 ? 0.0 : (pos.dx - x0) / (x1 - x0);
          final curveY = y0 + frac * (y1 - y0);
          if (pos.dy >= curveY - 6 && pos.dy <= plotRect.bottom) {
            return DiagramHoverStage(s.stage);
          }
        }
      }
    }

    return null;
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final lenSq = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lenSq < 1e-9) return (p - a).distance;
    final t = ((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / lenSq;
    final proj = Offset(
      a.dx + t.clamp(0.0, 1.0) * ab.dx,
      a.dy + t.clamp(0.0, 1.0) * ab.dy,
    );
    return (p - proj).distance;
  }
}

/// Draws a temperature–enthalpy (T–h) diagram for water/steam at constant
/// pressure using the real saturation dome from Table A-4 / A-5:
/// - Background two-phase saturation dome `(h_f(T), h_g(T))` up to the
///   critical point (373.95 °C, 2084.3 kJ/kg).
/// - Isobaric heating path through the 3 stages:
///   1. Liquid heating (T₁ → T_sat, h₁ → h_f, q₁ = h_f − h₁)
///   2. Evaporation at T_sat (h_f → h_g, q₂ = h_fg)
///   3. Superheating (T_sat → T₂, h_g → h₂, q₃ = h₂ − h_g)
/// - Shaded enthalpy bands beneath the x-axis showing how much heat (kJ/kg)
///   each stage uses, with labels, state points, and hover highlights.
class EnthalpyDiagramPainter extends CustomPainter {
  EnthalpyDiagramPainter({
    required this.result,
    required this.highlighted,
    this.hovered,
    required this.palette,
    required this.colorScheme,
    required this.l10n,
    required this.textStyle,
  });

  final SteamResult result;
  final SteamStage? highlighted;
  final DiagramHoverTarget? hovered;
  final HeatPalette palette;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final layout = EnthalpyDiagramLayout(size: size, result: result);
    final plotRect = layout.plotRect;
    final xOfH = layout.xOfH;
    final yOfT = layout.yOfT;

    final t1 = result.stages[0].tStart;
    final tSat = result.tSat;
    final t2 = result.stages[2].tEnd;

    final hoveredStage = switch (hovered) {
      DiagramHoverStage(:final stage) => stage,
      _ => null,
    };
    final hoveredPoint = switch (hovered) {
      DiagramHoverPoint(:final point) => point,
      _ => null,
    };
    final activeStage = hoveredStage ?? highlighted;

    // --- Plot background & grid ---------------------------------------------
    canvas.drawRRect(
      RRect.fromRectAndRadius(plotRect, const Radius.circular(8)),
      Paint()
        ..color = colorScheme.surfaceContainerLowest.withValues(alpha: 0.7),
    );

    _drawGrid(
      canvas,
      plotRect,
      layout.tMin,
      layout.tMax,
      layout.hMin,
      layout.hMax,
      xOfH,
      yOfT,
    );

    // --- Real two-phase saturation dome from Table A-4 ----------------------
    canvas.save();
    canvas.clipRect(plotRect);
    _drawSaturationDome(canvas, xOfH: xOfH, yOfT: yOfT);
    canvas.restore();

    // --- Dashed T_sat reference line ----------------------------------------
    final ySat = yOfT(tSat);
    _drawDashedLine(
      canvas,
      Offset(plotRect.left, ySat),
      Offset(plotRect.right, ySat),
      palette.mutedText.withValues(alpha: 0.45),
    );

    // --- Stage enthalpy bands & vertical drop lines -------------------------
    final brightness = colorScheme.brightness;

    // Vertical drop line at h₁ (start of liquid heating)
    _drawDashedVertical(
      canvas,
      xOfH(result.h1),
      math.min(yOfT(t1), plotRect.bottom),
      plotRect.bottom,
      steamStageColor(
        SteamStage.liquidHeating,
        brightness,
      ).withValues(alpha: 0.45),
    );

    for (final s in result.stages) {
      if (s.specificHeat <= 0 && s.stage == SteamStage.superheating) continue;
      final stageColor = steamStageColor(s.stage, brightness);
      final isSelected = activeStage == s.stage;
      final isDimmed = activeStage != null && !isSelected;

      final x0 = xOfH(s.hStart);
      final x1 = xOfH(s.hEnd);
      final y0 = yOfT(s.tStart);
      final y1 = yOfT(s.tEnd);

      // Shaded area under the stage segment down to the bottom of the plot.
      final areaPath = Path()
        ..moveTo(x0, plotRect.bottom)
        ..lineTo(x0, y0)
        ..lineTo(x1, y1)
        ..lineTo(x1, plotRect.bottom)
        ..close();

      final fillAlpha = isSelected
          ? 0.28
          : isDimmed
          ? 0.06
          : 0.14;
      canvas.drawPath(
        areaPath,
        Paint()..color = stageColor.withValues(alpha: fillAlpha),
      );

      // Vertical boundary dashed drop line at the end of the stage.
      _drawDashedVertical(
        canvas,
        x1,
        math.min(y1, plotRect.bottom),
        plotRect.bottom,
        stageColor.withValues(alpha: isDimmed ? 0.25 : 0.55),
      );

      // Stage bar along the bottom of the plot showing q_i (kJ/kg).
      final barRect = layout.stageBarRect(s.stage);
      if (barRect.width >= 2) {
        final rrect = RRect.fromRectAndRadius(
          barRect.deflate(0.8),
          const Radius.circular(4),
        );
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = stageColor.withValues(
              alpha: isSelected
                  ? 0.92
                  : isDimmed
                  ? 0.3
                  : 0.74,
            ),
        );
        if (isSelected) {
          canvas.drawRRect(
            rrect,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.6
              ..color = colorScheme.onSurface,
          );
        }

        final symbol = switch (s.stage) {
          SteamStage.liquidHeating => 'q₁',
          SteamStage.evaporation => 'q₂',
          SteamStage.superheating => 'q₃',
        };
        final fullLabel = '$symbol = ${fmtValue(s.specificHeat)} kJ/kg';
        final medLabel = '${fmtValue(s.specificHeat)} kJ/kg';
        final shortLabel = symbol;
        final labelStyle = textStyle.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        );
        final fullPainter = _layout(fullLabel, labelStyle);
        final medPainter = _layout(medLabel, labelStyle);
        final shortPainter = _layout(shortLabel, labelStyle);

        if (fullPainter.width + 8 <= barRect.width) {
          fullPainter.paint(
            canvas,
            Offset(
              barRect.center.dx - fullPainter.width / 2,
              barRect.center.dy - fullPainter.height / 2,
            ),
          );
        } else if (medPainter.width + 6 <= barRect.width) {
          medPainter.paint(
            canvas,
            Offset(
              barRect.center.dx - medPainter.width / 2,
              barRect.center.dy - medPainter.height / 2,
            ),
          );
        } else if (shortPainter.width + 4 <= barRect.width) {
          shortPainter.paint(
            canvas,
            Offset(
              barRect.center.dx - shortPainter.width / 2,
              barRect.center.dy - shortPainter.height / 2,
            ),
          );
        }
      }
    }

    // --- Isobaric heating path lines ----------------------------------------
    for (final s in result.stages) {
      if (s.specificHeat <= 0 && s.stage == SteamStage.superheating) continue;
      final stageColor = steamStageColor(s.stage, brightness);
      final isSelected = activeStage == s.stage;
      final isDimmed = activeStage != null && !isSelected;

      final p0 = Offset(xOfH(s.hStart), yOfT(s.tStart));
      final p1 = Offset(xOfH(s.hEnd), yOfT(s.tEnd));

      if (isSelected) {
        canvas.drawLine(
          p0,
          p1,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7.5
            ..strokeCap = StrokeCap.round
            ..color = stageColor.withValues(alpha: 0.30),
        );
      }

      canvas.drawLine(
        p0,
        p1,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 4.2 : 3.0
          ..strokeCap = StrokeCap.round
          ..color = stageColor.withValues(alpha: isDimmed ? 0.45 : 1.0),
      );
    }

    // --- Stage labels above/along segments ----------------------------------
    _drawStageAnnotations(canvas, plotRect, xOfH, yOfT, brightness);

    // --- Hovered point crosshairs -------------------------------------------
    if (hoveredPoint != null) {
      final pt = layout.pointOffset(hoveredPoint);
      final ptColor = pointColor(hoveredPoint, brightness);
      _drawDashedLine(
        canvas,
        Offset(plotRect.left, pt.dy),
        Offset(pt.dx, pt.dy),
        ptColor.withValues(alpha: 0.75),
      );
      _drawDashedVertical(
        canvas,
        pt.dx,
        pt.dy,
        plotRect.bottom,
        ptColor.withValues(alpha: 0.75),
      );
    }

    // --- State points (dots) ------------------------------------------------
    for (final pt in layout.activePoints) {
      final offset = layout.pointOffset(pt);
      final color = pointColor(pt, brightness);
      final isHovered = hoveredPoint == pt;
      _drawPoint(canvas, offset, color, hovered: isHovered);
    }

    // --- Point temperature / state callouts ---------------------------------
    final calloutStyle = textStyle.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: palette.text,
    );

    final ptStart = layout.pointOffset(DiagramStatePoint.startLiquid);
    final ptEnd = layout.pointOffset(DiagramStatePoint.endSteam);

    // T₁ label near start point
    _drawText(
      canvas,
      'T₁ = ${fmtTemp(t1)} °C',
      Offset(
        (ptStart.dx + 6).clamp(plotRect.left + 4, plotRect.right - 90),
        (ptStart.dy + 6).clamp(plotRect.top + 4, plotRect.bottom - 16),
      ),
      calloutStyle.copyWith(
        color: steamStageColor(SteamStage.liquidHeating, brightness),
      ),
    );

    // T₂ label near end point (if superheated)
    if (result.isSuperheated) {
      _drawText(
        canvas,
        'T₂ = ${fmtTemp(t2)} °C',
        Offset(
          math.min(ptEnd.dx - 4, plotRect.right - 6),
          math.max(plotRect.top + 4, ptEnd.dy - 18),
        ),
        calloutStyle.copyWith(
          color: steamStageColor(SteamStage.superheating, brightness),
        ),
        align: TextAlign.right,
      );
    }

    // --- Axes border and titles ---------------------------------------------
    canvas.drawRect(
      plotRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = palette.outline,
    );

    // Header: Isobar pressure badge + total specific heat
    _drawText(
      canvas,
      l10n.diagramIsobar(fmtInput(result.inputs.pressureBar)),
      Offset(plotRect.left, 6),
      textStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: colorScheme.primary,
      ),
    );
    _drawText(
      canvas,
      'q = ${fmtValue(result.qTotal)} kJ/kg',
      Offset(plotRect.right, 6),
      textStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: palette.text,
      ),
      align: TextAlign.right,
    );

    // Axis labels
    _drawText(
      canvas,
      l10n.diagramAxisTemp,
      Offset(6, 6),
      textStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: palette.mutedText,
      ),
    );
    _drawText(
      canvas,
      l10n.diagramAxisEnthalpy,
      Offset(plotRect.right, size.height - 15),
      textStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: palette.mutedText,
      ),
      align: TextAlign.right,
    );
  }

  static Color pointColor(DiagramStatePoint point, Brightness brightness) =>
      switch (point) {
        DiagramStatePoint.startLiquid => steamStageColor(
          SteamStage.liquidHeating,
          brightness,
        ),
        DiagramStatePoint.saturatedLiquid => steamStageColor(
          SteamStage.evaporation,
          brightness,
        ),
        DiagramStatePoint.saturatedSteam => steamStageColor(
          SteamStage.evaporation,
          brightness,
        ),
        DiagramStatePoint.endSteam => steamStageColor(
          SteamStage.superheating,
          brightness,
        ),
      };

  void _drawGrid(
    Canvas canvas,
    Rect plotRect,
    double tMin,
    double tMax,
    double hMin,
    double hMax,
    double Function(double) xOfH,
    double Function(double) yOfT,
  ) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = palette.outline.withValues(alpha: 0.22);

    final tickStyle = textStyle.copyWith(
      fontSize: 10,
      color: palette.mutedText,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    // Y-axis (temperature) ticks
    final tSpan = tMax - tMin;
    final tStep = tSpan > 260 ? 100.0 : (tSpan > 140 ? 50.0 : 25.0);
    final firstT = (tMin / tStep).ceil() * tStep;
    final ySat = yOfT(result.tSat);

    for (var t = firstT; t <= tMax; t += tStep) {
      final y = yOfT(t);
      canvas.drawLine(
        Offset(plotRect.left, y),
        Offset(plotRect.right, y),
        gridPaint,
      );
      if ((y - ySat).abs() > 13) {
        _drawText(
          canvas,
          t.toStringAsFixed(0),
          Offset(plotRect.left - 6, y - 6),
          tickStyle,
          align: TextAlign.right,
        );
      }
    }

    // Highlight T_sat on the Y-axis
    if (ySat >= plotRect.top && ySat <= plotRect.bottom) {
      _drawText(
        canvas,
        '${fmtTemp(result.tSat)}°',
        Offset(plotRect.left - 6, ySat - 6),
        tickStyle.copyWith(
          fontWeight: FontWeight.w700,
          color: steamStageColor(
            SteamStage.evaporation,
            colorScheme.brightness,
          ),
        ),
        align: TextAlign.right,
      );
    }

    // X-axis (enthalpy) ticks
    final hSpan = hMax - hMin;
    final hStep = hSpan > 2500 ? 1000.0 : (hSpan > 1200 ? 500.0 : 250.0);
    for (var h = 0.0; h <= hMax; h += hStep) {
      final x = xOfH(h);
      if (x < plotRect.left || x > plotRect.right) continue;
      canvas.drawLine(
        Offset(x, plotRect.top),
        Offset(x, plotRect.bottom),
        gridPaint,
      );
      _drawText(
        canvas,
        h.toStringAsFixed(0),
        Offset(x, plotRect.bottom + 28),
        tickStyle,
        align: TextAlign.center,
      );
    }
  }

  /// Draws the actual water/steam saturation dome from Table A-4:
  /// saturated liquid curve `h_f(T)` on the left and saturated vapour curve
  /// `h_g(T)` on the right, meeting at the critical point (373.95 °C).
  void _drawSaturationDome(
    Canvas canvas, {
    required double Function(double) xOfH,
    required double Function(double) yOfT,
  }) {
    final domePath = Path();
    for (var i = 0; i < tableA4.length; i++) {
      final (t, hf, _, _) = tableA4[i];
      final x = xOfH(hf);
      final y = yOfT(t);
      if (i == 0) {
        domePath.moveTo(x, y);
      } else {
        domePath.lineTo(x, y);
      }
    }
    for (var i = tableA4.length - 1; i >= 0; i--) {
      final (t, _, _, hg) = tableA4[i];
      final x = xOfH(hg);
      final y = yOfT(t);
      domePath.lineTo(x, y);
    }
    domePath.close();

    canvas.drawPath(
      domePath,
      Paint()..color = colorScheme.primary.withValues(alpha: 0.05),
    );
    canvas.drawPath(
      domePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = palette.mutedText.withValues(alpha: 0.30),
    );
  }

  void _drawStageAnnotations(
    Canvas canvas,
    Rect plotRect,
    double Function(double) xOfH,
    double Function(double) yOfT,
    Brightness brightness,
  ) {
    final evap = result[SteamStage.evaporation];
    final xMidEvap = (xOfH(evap.hStart) + xOfH(evap.hEnd)) / 2;
    final ySat = yOfT(result.tSat);

    final evapColor = steamStageColor(SteamStage.evaporation, brightness);
    final evapTitle = l10n.stageEvaporation;
    final evapValue = 'h_fg = ${fmtValue(evap.specificHeat)} kJ/kg';
    final topRoom = ySat - plotRect.top;
    final labelY = topRoom > 36 ? ySat - 30 : ySat + 8;

    _drawText(
      canvas,
      evapTitle,
      Offset(xMidEvap, labelY),
      textStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: evapColor,
      ),
      align: TextAlign.center,
    );
    _drawText(
      canvas,
      evapValue,
      Offset(xMidEvap, labelY + 13),
      textStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: palette.text,
      ),
      align: TextAlign.center,
    );
  }

  void _drawPoint(
    Canvas canvas,
    Offset center,
    Color color, {
    bool hovered = false,
  }) {
    if (hovered) {
      canvas.drawCircle(
        center,
        10.0,
        Paint()..color = color.withValues(alpha: 0.25),
      );
    }
    canvas.drawCircle(
      center,
      hovered ? 7.2 : 5.5,
      Paint()..color = colorScheme.surface,
    );
    canvas.drawCircle(center, hovered ? 5.6 : 4.2, Paint()..color = color);
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
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

  void _drawDashedVertical(
    Canvas canvas,
    double x,
    double topY,
    double bottomY,
    Color color,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = color;
    const dash = 4.0;
    const gap = 3.5;
    var y = topY;
    while (y < bottomY) {
      final end = math.min(y + dash, bottomY);
      canvas.drawLine(Offset(x, y), Offset(x, end), paint);
      y += dash + gap;
    }
  }

  TextPainter _layout(String text, TextStyle style) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _drawText(
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

  @override
  bool shouldRepaint(EnthalpyDiagramPainter oldDelegate) =>
      oldDelegate.result.inputs != result.inputs ||
      oldDelegate.highlighted != highlighted ||
      oldDelegate.hovered != hovered ||
      oldDelegate.palette != palette ||
      oldDelegate.colorScheme != colorScheme ||
      oldDelegate.l10n != l10n ||
      oldDelegate.textStyle != textStyle;
}
