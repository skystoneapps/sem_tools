import 'package:flutter/material.dart';

import '../../common/ui/number_field.dart';
import '../../common/ui/number_format.dart';
import '../../common/ui/stat_tiles.dart';
import '../../common/ui/tex_formula.dart';
import '../../heat_transfer/domain/physics.dart';
import '../../heat_transfer/ui/formula_text.dart';
import '../../heat_transfer/ui/heat_palette.dart';
import '../../l10n/app_localizations.dart';
import '../domain/steam_model.dart';
import 'enthalpy_diagram_painter.dart';
import 'steam_controller.dart';

const _texKjPerKg = r'\,\mathrm{kJ/kg}';
const _texKw = r'\,\mathrm{kW}';
const _texMw = r'\,\mathrm{MW}';
const _texKgPerS = r'\,\mathrm{kg/s}';

extension _SteamStageLabels on SteamStage {
  String title(AppLocalizations l10n) => switch (this) {
    SteamStage.liquidHeating => l10n.stageLiquidHeating,
    SteamStage.evaporation => l10n.stageEvaporation,
    SteamStage.superheating => l10n.stageSuperheating,
  };

  String path(AppLocalizations l10n) => switch (this) {
    SteamStage.liquidHeating => l10n.stageLiquidHeatingPath,
    SteamStage.evaporation => l10n.stageEvaporationPath,
    SteamStage.superheating => l10n.stageSuperheatingPath,
  };

  String law(AppLocalizations l10n) => switch (this) {
    SteamStage.liquidHeating => l10n.lawSensibleHeat,
    SteamStage.evaporation => l10n.lawLatentHeat,
    SteamStage.superheating => l10n.lawSuperheat,
  };
}

/// Steam generation & T–h diagram: the diagram, variables and stage table on
/// the left, and the worked calculation of the selected stage (or total) on
/// the right.
class SteamScreen extends StatelessWidget {
  const SteamScreen({super.key, required this.controller});

  final SteamController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context);
        final result = calculateSteam(controller.inputs);

        final diagram = _DiagramView(
          result: result,
          selected: controller.selected,
          onSelected: (s) => controller.selected = s,
        );
        final variables = _VariablesCard(
          controller: controller,
          result: result,
        );
        final results = _ResultsSection(
          result: result,
          selected: controller.selected,
          onSelected: (s) => controller.selected = s,
        );
        final details = _SteamDetailsPane(
          result: result,
          selected: controller.selected,
          onSelected: (s) => controller.selected = s,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  diagram,
                  const SizedBox(height: 8),
                  variables,
                  results,
                  const SizedBox(height: 24),
                  Text(l10n.calculation, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  details,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    children: [
                      diagram,
                      const SizedBox(height: 8),
                      variables,
                      results,
                    ],
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                SizedBox(
                  width: (constraints.maxWidth * 0.45).clamp(420, 620),
                  child: ColoredBox(
                    color: theme.colorScheme.surfaceContainerLow,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      children: [details],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DiagramView extends StatefulWidget {
  const _DiagramView({
    required this.result,
    required this.selected,
    required this.onSelected,
  });

  final SteamResult result;
  final SteamStage? selected;
  final ValueChanged<SteamStage?> onSelected;

  @override
  State<_DiagramView> createState() => _DiagramViewState();
}

class _DiagramViewState extends State<_DiagramView> {
  DiagramHoverTarget? _hovered;

  void _updateHover(Offset localPos, Size size) {
    final layout = EnthalpyDiagramLayout(size: size, result: widget.result);
    final hit = layout.hitTest(localPos);
    if (hit != _hovered) {
      setState(() => _hovered = hit);
    }
  }

  void _handleTap(Offset localPos, Size size) {
    final layout = EnthalpyDiagramLayout(size: size, result: widget.result);
    final hit = layout.hitTest(localPos);
    setState(() => _hovered = hit);
    if (hit is DiagramHoverStage) {
      widget.onSelected(hit.stage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hovered = _hovered;
    return SizedBox(
      height: 300,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, 300);
          final layout = EnthalpyDiagramLayout(
            size: size,
            result: widget.result,
          );

          Widget? tooltip;
          if (hovered != null) {
            final anchor = layout.anchorFor(hovered);
            const cardWidth = 268.0;
            const cardHeight = 76.0;
            final left = (anchor.dx - cardWidth / 2).clamp(
              layout.plotRect.left + 6,
              (size.width - cardWidth - 8).clamp(0.0, double.infinity),
            );
            final preferAbove = anchor.dy - cardHeight - 14;
            final top = preferAbove >= layout.plotRect.top + 4
                ? preferAbove
                : (anchor.dy + 14).clamp(
                    layout.plotRect.top + 4,
                    size.height - cardHeight - 4,
                  );

            tooltip = Positioned(
              left: left,
              top: top,
              width: cardWidth,
              child: IgnorePointer(
                child: _DiagramHoverCard(
                  result: widget.result,
                  target: hovered,
                ),
              ),
            );
          }

          return MouseRegion(
            cursor: hovered is DiagramHoverStage
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onHover: (e) => _updateHover(e.localPosition, size),
            onExit: (_) {
              if (_hovered != null) setState(() => _hovered = null);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _handleTap(d.localPosition, size),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: EnthalpyDiagramPainter(
                          result: widget.result,
                          highlighted: widget.selected,
                          hovered: hovered,
                          palette: HeatPalette.of(context),
                          colorScheme: Theme.of(context).colorScheme,
                          l10n: AppLocalizations.of(context),
                          textStyle: DefaultTextStyle.of(
                            context,
                          ).style.copyWith(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  ?tooltip,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DiagramHoverCard extends StatelessWidget {
  const _DiagramHoverCard({required this.result, required this.target});

  final SteamResult result;
  final DiagramHoverTarget target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final brightness = theme.colorScheme.brightness;
    final pBar = fmtInput(result.inputs.pressureBar);
    final pKpa = fmtInput(result.inputs.pressureKpa);

    final (Color accent, String title, String primaryValue, String details) =
        switch (target) {
          DiagramHoverPoint(:final point) => switch (point) {
            DiagramStatePoint.startLiquid => (
              EnthalpyDiagramPainter.pointColor(point, brightness),
              l10n.pointStartLiquid,
              'h₁ = ${fmtValue(result.h1)} kJ/kg',
              'T₁ = ${fmtTemp(result.stages[0].tStart)} °C  ·  P = $pBar bar ($pKpa kPa)',
            ),
            DiagramStatePoint.saturatedLiquid => (
              EnthalpyDiagramPainter.pointColor(point, brightness),
              l10n.pointSaturatedLiquid,
              'h_f = ${fmtValue(result.hf)} kJ/kg',
              'Tₛₐₜ = ${fmtTemp(result.tSat)} °C  ·  P = $pBar bar ($pKpa kPa)',
            ),
            DiagramStatePoint.saturatedSteam => (
              EnthalpyDiagramPainter.pointColor(point, brightness),
              l10n.pointSaturatedSteam,
              'h_g = ${fmtValue(result.hg)} kJ/kg',
              'Tₛₐₜ = ${fmtTemp(result.tSat)} °C  ·  P = $pBar bar ($pKpa kPa)',
            ),
            DiagramStatePoint.endSteam => (
              EnthalpyDiagramPainter.pointColor(point, brightness),
              l10n.pointEndSteam,
              'h₂ = ${fmtValue(result.h2)} kJ/kg',
              'T₂ = ${fmtTemp(result.stages[2].tEnd)} °C  ·  P = $pBar bar ($pKpa kPa)',
            ),
          },
          DiagramHoverStage(:final stage) => () {
            final s = result[stage];
            final symbol = switch (stage) {
              SteamStage.liquidHeating => 'q₁',
              SteamStage.evaporation => 'q₂ = h_fg',
              SteamStage.superheating => 'q₃',
            };
            final share = result.qTotal > 0
                ? s.specificHeat / result.qTotal * 100
                : 0.0;
            final powerPart = result.inputs.includeFlow
                ? '  ·  ${fmtValue(result.stagePowerKw(stage))} kW'
                : '';
            return (
              steamStageColor(stage, brightness),
              stage.title(l10n),
              '$symbol = ${fmtValue(s.specificHeat)} kJ/kg (${fmtValue(share)} %)$powerPart',
              '${fmtTemp(s.tStart)} → ${fmtTemp(s.tEnd)} °C  ·  '
                  '${fmtValue(s.hStart)} → ${fmtValue(s.hEnd)} kJ/kg  ·  P = $pBar bar',
            );
          }(),
        };

    return Material(
      elevation: 4,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: accent.withValues(alpha: 0.7), width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            FormulaText(
              primaryValue,
              symbolTooltips: false,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
            FormulaText(
              details,
              symbolTooltips: false,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariablesCard extends StatelessWidget {
  const _VariablesCard({required this.controller, required this.result});

  final SteamController controller;
  final SteamResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final inputs = controller.inputs;

    final pressurePresets = <(String, double)>[
      (l10n.presetAtmospheric, 1.01325),
      (l10n.presetLowPressureSteam, 2.0),
      (l10n.presetMediumPressureSteam, 5.0),
      (l10n.presetIndustrialSteam, 10.0),
      (l10n.presetHighPressureSteam, 20.0),
      (l10n.presetPowerPlantSteam, 40.0),
    ];

    final conditionFields = [
      NumberField(
        key: const ValueKey('pressureBar'),
        symbol: 'P',
        label: l10n.steamFieldPressure,
        unit: 'bar',
        value: inputs.pressureBar,
        min: 0.01,
        minInclusive: true,
        max: waterCriticalPressureBar,
        presets: pressurePresets,
        onChanged: (v) => controller.inputs = inputs.copyWith(pressureBar: v),
      ),
      NumberField(
        key: const ValueKey('startTemp'),
        symbol: 'T₁',
        label: l10n.steamFieldStartTemp,
        unit: '°C',
        value: inputs.startTemp,
        min: 0,
        minInclusive: true,
        max: waterCriticalTempCelsius,
        presets: [
          (l10n.presetWater10, 10),
          (l10n.presetWater20, 20),
          (l10n.presetWater60, 60),
          (l10n.presetWater80, 80),
        ],
        onChanged: (v) => controller.inputs = inputs.copyWith(startTemp: v),
      ),
      NumberField(
        key: const ValueKey('steamTemp'),
        symbol: 'T₂',
        label: l10n.steamFieldSteamTemp,
        unit: '°C',
        value: inputs.steamTemp,
        min: -kelvinOffset,
        presets: [
          (l10n.presetBoilingPoint, result.tSat),
          ('150 °C', 150),
          ('200 °C', 200),
          ('250 °C', 250),
          ('300 °C', 300),
          ('400 °C', 400),
        ],
        onChanged: (v) => controller.inputs = inputs.copyWith(steamTemp: v),
      ),
    ];

    final flowUnitLabel = inputs.flowUnit == SteamFlowUnit.tonPerHour
        ? l10n.steamUnitTonPerHour
        : l10n.steamUnitKgPerSecond;
    final flowPresets = inputs.flowUnit == SteamFlowUnit.tonPerHour
        ? const <(String, double)>[
            ('0.5 ton/h', 0.5),
            ('1.5 ton/h', 1.5),
            ('5 ton/h', 5.0),
            ('10 ton/h', 10.0),
          ]
        : const <(String, double)>[
            ('0.1 kg/s', 0.1),
            ('0.5 kg/s', 0.5),
            ('1 kg/s', 1.0),
            ('5 kg/s', 5.0),
          ];

    Widget buildGrid(List<Widget> fields) {
      return LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 12.0;
          final columns = (constraints.maxWidth / 190)
              .floor()
              .clamp(1, fields.length);
          final width =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final field in fields) SizedBox(width: width, child: field),
            ],
          );
        },
      );
    }

    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Text(l10n.variables, style: theme.textTheme.titleSmall),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                l10n.steamSectionConditions,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            buildGrid(conditionFields),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.table_chart_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: FormulaText(
                      l10n.steamTableSummary(
                        fmtInput(inputs.pressureBar),
                        fmtInput(inputs.pressureKpa),
                        fmtTemp(result.tSat),
                        fmtValue(result.hf),
                        fmtValue(result.hfg),
                        fmtValue(result.hg),
                      ),
                      symbolTooltips: false,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 4),
              child: Text(
                l10n.steamSectionFlow,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            CheckboxListTile(
              value: inputs.includeFlow,
              onChanged: (v) =>
                  controller.inputs = inputs.copyWith(includeFlow: v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(l10n.steamIncludeFlow),
            ),
            if (inputs.includeFlow) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    child: NumberField(
                      key: ValueKey('flowRate_${inputs.flowUnit.name}'),
                      symbol: 'ṁ',
                      label: l10n.steamFieldFlowRate,
                      unit: flowUnitLabel,
                      value: inputs.flowRate,
                      min: 0,
                      presets: flowPresets,
                      onChanged: (v) =>
                          controller.inputs = inputs.copyWith(flowRate: v),
                    ),
                  ),
                  SegmentedButton<SteamFlowUnit>(
                    segments: [
                      ButtonSegment(
                        value: SteamFlowUnit.tonPerHour,
                        label: Text(l10n.steamUnitTonPerHour),
                      ),
                      ButtonSegment(
                        value: SteamFlowUnit.kgPerSecond,
                        label: Text(l10n.steamUnitKgPerSecond),
                      ),
                    ],
                    selected: {inputs.flowUnit},
                    onSelectionChanged: (s) {
                      controller.inputs = inputs.copyWith(flowUnit: s.first);
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({
    required this.result,
    required this.selected,
    required this.onSelected,
  });

  final SteamResult result;
  final SteamStage? selected;
  final ValueChanged<SteamStage?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final brightness = theme.colorScheme.brightness;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final showFlow = result.inputs.includeFlow;

    final statTiles = <(String, String)>[
      (l10n.statSpecificHeatTotal, '${fmtValue(result.qTotal)} kJ/kg'),
      (l10n.statBoilingTemperature, '${fmtTemp(result.tSat)} °C'),
      (l10n.statDegreeOfSuperheat, '${fmtTemp(result.superheatDeltaT)} K'),
      if (showFlow) (l10n.statThermalPower, '${fmtValue(result.powerKw)} kW'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            l10n.results,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        StatRow(statTiles),
        if (!result.startTempValid) ...[
          const SizedBox(height: 12),
          _Banner(
            isError: true,
            message: l10n.steamStartAboveBoiling(
              fmtTemp(result.inputs.startTemp),
              fmtTemp(result.tSat),
              fmtInput(result.inputs.pressureBar),
            ),
          ),
        ],
        if (!result.steamTempValid) ...[
          const SizedBox(height: 12),
          _Banner(
            isError: true,
            message: l10n.steamTargetBelowBoiling(
              fmtTemp(result.inputs.steamTemp),
              fmtTemp(result.tSat),
              fmtInput(result.inputs.pressureBar),
            ),
          ),
        ] else if (!result.isSuperheated) ...[
          const SizedBox(height: 12),
          _Banner(
            isError: false,
            message: l10n.steamSaturatedNote(fmtTemp(result.tSat)),
          ),
        ],
        const SizedBox(height: 12),
        Card.outlined(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final numberWidth = showFlow
                  ? (constraints.maxWidth < 520 ? 68.0 : 92.0)
                  : (constraints.maxWidth < 460 ? 78.0 : 108.0);
              return Column(
                children: [
                  _StageRow(
                    numberWidth: numberWidth,
                    title: Text(l10n.resultsStage, style: muted),
                    values: [
                      'ΔT  [K]',
                      'q  [kJ/kg]',
                      if (showFlow) 'Q̇  [kW]',
                      '%',
                    ],
                    valueStyle: muted,
                  ),
                  const Divider(height: 1),
                  for (final s in result.stages)
                    _StageRow(
                      numberWidth: numberWidth,
                      accent: steamStageColor(s.stage, brightness),
                      selected: selected == s.stage,
                      dimmed:
                          s.stage == SteamStage.superheating &&
                          !result.isSuperheated,
                      onTap: () => onSelected(s.stage),
                      leading: Icon(
                        steamStageIcon(s.stage),
                        size: 18,
                        color: steamStageColor(s.stage, brightness),
                      ),
                      title: _RowTitle(
                        s.stage.title(l10n),
                        s.stage.path(l10n),
                      ),
                      values: [
                        fmtTemp(s.deltaT),
                        fmtValue(s.specificHeat),
                        if (showFlow) fmtValue(result.stagePowerKw(s.stage)),
                        result.qTotal > 0
                            ? '${fmtValue(s.specificHeat / result.qTotal * 100)} %'
                            : '0 %',
                      ],
                    ),
                  const Divider(height: 1),
                  _StageRow(
                    numberWidth: numberWidth,
                    accent: theme.colorScheme.primary,
                    selected: selected == null,
                    onTap: () => onSelected(null),
                    leading: Icon(
                      Icons.functions,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    title: _RowTitle(
                      l10n.total,
                      l10n.steamTotalPath(fmtInput(result.inputs.pressureBar)),
                    ),
                    values: [
                      fmtTemp(
                        result.stages.last.tEnd - result.stages.first.tStart,
                      ),
                      fmtValue(result.qTotal),
                      if (showFlow) fmtValue(result.powerKw),
                      '100 %',
                    ],
                    valueStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RowTitle extends StatelessWidget {
  const _RowTitle(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, overflow: TextOverflow.ellipsis),
        FormulaText(
          subtitle,
          symbolTooltips: false,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.numberWidth,
    required this.title,
    required this.values,
    this.leading,
    this.accent,
    this.selected = false,
    this.dimmed = false,
    this.onTap,
    this.valueStyle,
  });

  final double numberWidth;
  final Widget title;
  final List<String> values;
  final Widget? leading;
  final Color? accent;
  final bool selected;
  final bool dimmed;
  final VoidCallback? onTap;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent;
    return Material(
      color: selected && color != null
          ? color.withValues(alpha: 0.1)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 4,
                color: selected && color != null ? color : Colors.transparent,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
          child: Opacity(
            opacity: dimmed ? 0.45 : 1.0,
            child: Row(
              children: [
                SizedBox(width: 26, child: leading),
                Expanded(child: title),
                for (final value in values)
                  SizedBox(
                    width: numberWidth,
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: (valueStyle ?? theme.textTheme.bodyMedium)
                          ?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.isError, required this.message});

  final bool isError;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isError ? scheme.errorContainer : scheme.secondaryContainer;
    final fg = isError ? scheme.onErrorContainer : scheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 20,
            color: fg,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FormulaText(
              message,
              symbolTooltips: false,
              style: TextStyle(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

class _SteamDetailsPane extends StatelessWidget {
  const _SteamDetailsPane({
    required this.result,
    required this.selected,
    required this.onSelected,
  });

  final SteamResult result;
  final SteamStage? selected;
  final ValueChanged<SteamStage?> onSelected;

  @override
  Widget build(BuildContext context) {
    final stage = selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StagePicker(selected: stage, onSelected: onSelected),
        const SizedBox(height: 20),
        if (stage == null)
          _TotalSteamDerivation(result: result)
        else
          _StageSteamDerivation(result: result, stage: result[stage]),
      ],
    );
  }
}

class _StagePicker extends StatelessWidget {
  const _StagePicker({required this.selected, required this.onSelected});

  final SteamStage? selected;
  final ValueChanged<SteamStage?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.colorScheme.brightness;
    final current = selected;

    Widget leading(SteamStage? stage) => stage == null
        ? Icon(Icons.functions, color: theme.colorScheme.primary)
        : Icon(
            steamStageIcon(stage),
            color: steamStageColor(stage, brightness),
          );

    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        style: MenuStyle(
          minimumSize: WidgetStatePropertyAll(Size(constraints.maxWidth, 0)),
          maximumSize: WidgetStatePropertyAll(
            Size(constraints.maxWidth, double.infinity),
          ),
        ),
        menuChildren: [
          for (final stage in [...SteamStage.values, null]) ...[
            if (stage == null) const Divider(height: 8),
            MenuItemButton(
              leadingIcon: leading(stage),
              trailingIcon: stage == current
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onPressed: () => onSelected(stage),
              child: _PickerLabel(stage: stage),
            ),
          ],
        ],
        builder: (context, controller, _) => Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () =>
                controller.isOpen ? controller.close() : controller.open(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  leading(current),
                  const SizedBox(width: 14),
                  Expanded(child: _PickerLabel(stage: current, large: true)),
                  Icon(
                    controller.isOpen
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerLabel extends StatelessWidget {
  const _PickerLabel({required this.stage, this.large = false});

  final SteamStage? stage;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final s = stage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          s?.title(l10n) ?? l10n.total,
          style: large ? theme.textTheme.titleMedium : null,
        ),
        FormulaText(
          s == null
              ? l10n.totalSubtitle
              : '${s.law(l10n)}  ·  ${s.path(l10n)}',
          symbolTooltips: false,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StageSteamDerivation extends StatelessWidget {
  const _StageSteamDerivation({required this.result, required this.stage});

  final SteamResult result;
  final SteamStageResult stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final color = steamStageColor(stage.stage, theme.colorScheme.brightness);
    final share = result.qTotal > 0
        ? stage.specificHeat / result.qTotal * 100
        : 0.0;

    final inputs = result.inputs;
    final t1 = texTemp(stage.tStart);
    final tSat = texTemp(result.tSat);
    final t2 = texTemp(stage.tEnd);
    final h1 = texValue(result.h1);
    final hf = texValue(result.hf);
    final hg = texValue(result.hg);
    final h2 = texValue(result.h2);
    final q = texValue(stage.specificHeat);

    final (
      String formula,
      List<DerivationStep> steps,
      List<LegendEntry> legend,
    ) = switch (stage.stage) {
      SteamStage.liquidHeating => (
        r'q_1 = h_f - h_1',
        [
          (
            l10n.steamStepH1,
            'h_1 \\approx h_{f\\text{ @ }T_1}($t1$texCelsius) = '
                '$h1$_texKjPerKg',
          ),
          (
            l10n.steamStepHf,
            'T_{\\mathrm{sat}}(${texInput(inputs.pressureKpa)}\\,\\mathrm{kPa}) = '
                '$tSat$texCelsius, \\quad h_f = $hf$_texKjPerKg',
          ),
          (
            l10n.steamStepLiquidHeat,
            'q_1 = h_f - h_1 = $hf - $h1 = $q$_texKjPerKg',
          ),
        ],
        [
          ('q_1', l10n.symbolSpecificHeatLiquid, 'kJ/kg'),
          ('h_1', l10n.symbolEnthalpyStart, 'kJ/kg'),
          ('h_f', l10n.symbolEnthalpySatLiquid, 'kJ/kg'),
          ('T_1', l10n.symbolStartTemp, '°C'),
          (r'T_{\mathrm{sat}}', l10n.symbolBoilingTemp, '°C'),
        ],
      ),
      SteamStage.evaporation => (
        r'q_2 = h_{fg} = h_g - h_f',
        [
          (
            l10n.steamStepEvaporation,
            'q_2 = h_g - h_f = $hg - $hf = $q$_texKjPerKg '
                '\\quad (T_{\\mathrm{sat}} = $tSat$texCelsius)',
          ),
        ],
        [
          (r'q_2 = h_{fg}', l10n.symbolSpecificHeatEvap, 'kJ/kg'),
          ('h_f', l10n.symbolEnthalpySatLiquid, 'kJ/kg'),
          ('h_g', l10n.symbolEnthalpySatVapour, 'kJ/kg'),
          ('P', l10n.symbolPressure, 'bar'),
          (r'T_{\mathrm{sat}}', l10n.symbolBoilingTemp, '°C'),
        ],
      ),
      SteamStage.superheating => (
        r'q_3 = h_2 - h_g',
        [
          (
            l10n.steamStepH2,
            'h_2(${texInput(inputs.pressureMpa)}\\,\\mathrm{MPa},\\, '
                '$t2$texCelsius) = $h2$_texKjPerKg',
          ),
          (
            l10n.steamStepSuperheat,
            'q_3 = h_2 - h_g = $h2 - $hg = $q$_texKjPerKg',
          ),
        ],
        [
          ('q_3', l10n.symbolSpecificHeatSuper, 'kJ/kg'),
          ('h_g', l10n.symbolEnthalpySatVapour, 'kJ/kg'),
          ('h_2', l10n.symbolEnthalpySteam, 'kJ/kg'),
          ('T_2', l10n.symbolSteamTemp, '°C'),
          (r'T_{\mathrm{sat}}', l10n.symbolBoilingTemp, '°C'),
        ],
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatRow([
          (l10n.statStageSpecificHeat, '${fmtValue(stage.specificHeat)} kJ/kg'),
          (l10n.symbolTemperatureDifference, '${fmtTemp(stage.deltaT)} K'),
          (l10n.statShareOfTotal, '${fmtValue(share)} %'),
          if (inputs.includeFlow)
            (
              l10n.statThermalPower,
              '${fmtValue(result.stagePowerKw(stage.stage))} kW',
            ),
        ]),
        const SizedBox(height: 8),
        Text(
          '${fmtTemp(stage.tStart)} °C → ${fmtTemp(stage.tEnd)} °C   ·   '
          '${fmtValue(stage.hStart)} → ${fmtValue(stage.hEnd)} kJ/kg',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Derivation(
          color: color,
          law: stage.stage.law(l10n),
          formula: formula,
          steps: steps,
          legend: legend,
        ),
      ],
    );
  }
}

class _TotalSteamDerivation extends StatelessWidget {
  const _TotalSteamDerivation({required this.result});

  final SteamResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final inputs = result.inputs;

    final t1 = texTemp(result.stages.first.tStart);
    final tSat = texTemp(result.tSat);
    final t2 = texTemp(result.stages.last.tEnd);
    final h1 = texValue(result.h1);
    final hf = texValue(result.hf);
    final hg = texValue(result.hg);
    final h2 = texValue(result.h2);
    final q1 = texValue(result.qLiquid);
    final q2 = texValue(result.qEvaporation);
    final q3 = texValue(result.qSuperheat);
    final qTot = texValue(result.qTotal);

    return Derivation(
      color: theme.colorScheme.primary,
      law: l10n.lawIsobaricEnthalpy,
      formula: inputs.includeFlow
          ? r'q = h_2 - h_1 = q_1 + q_2 + q_3, \quad \dot{Q} = \dot{m}\,q'
          : r'q = h_2 - h_1 = q_1 + q_2 + q_3',
      steps: [
        (
          l10n.steamStepH1,
          'h_1 \\approx h_{f\\text{ @ }T_1}($t1$texCelsius) = '
              '$h1$_texKjPerKg',
        ),
        (
          l10n.steamStepHf,
          'T_{\\mathrm{sat}}(${texInput(inputs.pressureKpa)}\\,\\mathrm{kPa}) = '
              '$tSat$texCelsius, \\quad h_f = $hf$_texKjPerKg, \\quad '
              'h_g = $hg$_texKjPerKg',
        ),
        (
          l10n.steamStepH2,
          'h_2(${texInput(inputs.pressureMpa)}\\,\\mathrm{MPa},\\, '
              '$t2$texCelsius) = $h2$_texKjPerKg',
        ),
        (
          l10n.steamStepLiquidHeat,
          'q_1 = h_f - h_1 = $hf - $h1 = $q1$_texKjPerKg',
        ),
        (
          l10n.steamStepEvaporation,
          'q_2 = h_{fg} = h_g - h_f = $hg - $hf = $q2$_texKjPerKg',
        ),
        (
          l10n.steamStepSuperheat,
          'q_3 = h_2 - h_g = $h2 - $hg = $q3$_texKjPerKg',
        ),
        (
          l10n.steamStepTotalSpecific,
          'q = h_2 - h_1 = $h2 - $h1 = $qTot$_texKjPerKg',
        ),
        if (inputs.includeFlow) ...[
          if (inputs.flowUnit == SteamFlowUnit.tonPerHour)
            (
              l10n.steamStepMassFlowConvert,
              '\\dot{m} = \\frac{${texInput(inputs.flowRate)}\\,\\mathrm{t/h} '
                  '\\cdot 1000\\,\\mathrm{kg/t}}{3600\\,\\mathrm{s/h}} = '
                  '${texValue(result.massFlowKgPerS)}$_texKgPerS',
            ),
          (
            l10n.steamStepThermalPower,
            '\\dot{Q} = \\dot{m}\\,q = '
                '${texValue(result.massFlowKgPerS)}$_texKgPerS \\cdot '
                '$qTot$_texKjPerKg = ${texValue(result.powerKw)}$_texKw '
                '\\; (${texValue(result.powerMw)}$_texMw)',
          ),
        ],
      ],
      legend: [
        ('q', l10n.symbolSpecificHeatTotal, 'kJ/kg'),
        ('q_1', l10n.symbolSpecificHeatLiquid, 'kJ/kg'),
        (r'q_2 = h_{fg}', l10n.symbolSpecificHeatEvap, 'kJ/kg'),
        ('q_3', l10n.symbolSpecificHeatSuper, 'kJ/kg'),
        ('h_1', l10n.symbolEnthalpyStart, 'kJ/kg'),
        ('h_f', l10n.symbolEnthalpySatLiquid, 'kJ/kg'),
        ('h_g', l10n.symbolEnthalpySatVapour, 'kJ/kg'),
        ('h_2', l10n.symbolEnthalpySteam, 'kJ/kg'),
        ('P', l10n.symbolPressure, 'bar'),
        ('T_1', l10n.symbolStartTemp, '°C'),
        (r'T_{\mathrm{sat}}', l10n.symbolBoilingTemp, '°C'),
        ('T_2', l10n.symbolSteamTemp, '°C'),
        if (inputs.includeFlow) ...[
          (r'\dot{m}', l10n.symbolSteamFlow, 'kg/s'),
          (r'\dot{Q}', l10n.symbolThermalPower, 'kW'),
        ],
      ],
    );
  }
}
