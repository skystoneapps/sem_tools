import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'formula_text.dart';
import 'heat_labels.dart';
import 'heat_model.dart';
import 'heat_palette.dart';

/// Right-hand pane: a picker for the stage to inspect, followed by that
/// stage's step-by-step calculation. A `null` selection shows how the stages
/// combine into the total.
class DetailsPane extends StatelessWidget {
  const DetailsPane({
    super.key,
    required this.result,
    required this.selected,
    required this.onSelected,
  });

  final HeatTransferResult result;
  final HeatStage? selected;
  final ValueChanged<HeatStage?> onSelected;

  @override
  Widget build(BuildContext context) {
    final stage = selected;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _StagePicker(selected: stage, onSelected: onSelected),
        const SizedBox(height: 20),
        if (stage == null)
          _TotalDetails(result: result)
        else
          _StageDetails(result: result, stage: result[stage]),
      ],
    );
  }
}

/// Full-width picker listing every stage in the order heat travels, plus the
/// total.
class _StagePicker extends StatelessWidget {
  const _StagePicker({required this.selected, required this.onSelected});

  final HeatStage? selected;
  final ValueChanged<HeatStage?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = HeatPalette.of(context);
    final current = selected;

    Widget leading(HeatStage? stage) => stage == null
        ? Icon(Icons.functions, color: theme.colorScheme.primary)
        : Icon(
            mechanismIcon(stage.mechanism),
            color: palette.mechanism(stage.mechanism),
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
          for (final stage in [...HeatStage.values, null]) ...[
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

  final HeatStage? stage;
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
        Text(
          s == null
              ? l10n.totalSubtitle
              : '${s.mechanism.law(l10n)}  ·  ${s.path(l10n)}',
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of [_StatTile]s that wraps to two columns when narrow.
class _StatRow extends StatelessWidget {
  const _StatRow(this.tiles);

  final List<(String, String)> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final columns = constraints.maxWidth > 140.0 * tiles.length
            ? tiles.length
            : 2;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final (label, value) in tiles)
              SizedBox(
                width: width,
                child: _StatTile(label: label, value: value),
              ),
          ],
        );
      },
    );
  }
}

/// The law box followed by the worked steps.
class _Derivation extends StatelessWidget {
  const _Derivation({
    required this.color,
    required this.law,
    required this.formula,
    required this.steps,
  });

  final Color color;
  final String law;
  final String formula;
  final List<_Step> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formulaStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      height: 1.5,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                law,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              FormulaText(formula, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        for (final (index, (label, formula)) in steps.indexed)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(color: color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FormulaText(formula, style: formulaStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StageDetails extends StatelessWidget {
  const _StageDetails({required this.result, required this.stage});

  final HeatTransferResult result;
  final StageResult stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final palette = HeatPalette.of(context);
    final outer =
        stage.stage == HeatStage.outerConvection ||
        stage.stage == HeatStage.outerRadiation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatRow([
          (l10n.statHeatFlow, '${fmt(stage.heatRate)} W'),
          (l10n.statResistance, '${fmt(stage.resistance)} K/W'),
          (l10n.statTemperatureDrop, '${fmt(stage.deltaT)} K'),
        ]),
        const SizedBox(height: 8),
        FormulaText(
          '${fmtTemp(stage.tIn)} °C → ${fmtTemp(stage.tOut)} °C',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        _Derivation(
          color: palette.mechanism(stage.stage.mechanism),
          law: stage.stage.mechanism.law(l10n),
          formula: _lawFormula(stage.stage),
          steps: _stepsFor(result, stage, l10n),
        ),
        if (outer) ...[
          const SizedBox(height: 20),
          FormulaText(
            l10n.surfaceIterationNote,
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// How the stages combine into the total heat flow.
class _TotalDetails extends StatelessWidget {
  const _TotalDetails({required this.result});

  final HeatTransferResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final conv = result[HeatStage.outerConvection];
    final rad = result[HeatStage.outerRadiation];
    final series = [
      result[HeatStage.innerConvection],
      result[HeatStage.pipeConduction],
      result[HeatStage.insulationConduction],
    ].map((s) => fmt(s.resistance)).join(' + ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatRow([
          (l10n.statHeatFlow, '${fmt(result.heatRate)} W'),
          (l10n.statTotalResistance, '${fmt(result.totalResistance)} K/W'),
          (
            l10n.statTemperatureDrop,
            '${fmt(result.fluidTemp - result.ambientTemp)} K',
          ),
        ]),
        const SizedBox(height: 20),
        _Derivation(
          color: theme.colorScheme.primary,
          law: l10n.lawSeries,
          formula: 'Q = (T_f − T_∞) / ΣR',
          steps: [
            (
              l10n.stepParallel,
              'R_{out} = (1/R_{conv,o} + 1/R_{rad})^{−1} = '
                  '(1/${fmt(conv.resistance)} + 1/${fmt(rad.resistance)})^{−1}'
                  ' = ${fmt(result.outerResistance)} K/W',
            ),
            (
              l10n.stepSeries,
              'ΣR = R_{conv,i} + R_{pipe} + R_{ins} + R_{out} = $series + '
                  '${fmt(result.outerResistance)} = '
                  '${fmt(result.totalResistance)} K/W',
            ),
            (
              l10n.stepTotalHeatFlow,
              'Q = (T_f − T_∞) / ΣR = (${fmtTemp(result.fluidTemp)} − '
                  '${fmtTemp(result.ambientTemp)}) / '
                  '${fmt(result.totalResistance)} = ${fmt(result.heatRate)} W',
            ),
            (
              l10n.stepHeatFlowPerMetre,
              "q' = Q / L = ${fmt(result.heatRate)} / "
                  '${fmtInput(result.inputs.length)} = '
                  '${fmt(result.heatRatePerMetre)} W/m',
            ),
          ],
        ),
      ],
    );
  }
}

typedef _Step = (String, String);

List<_Step> _stepsFor(
  HeatTransferResult result,
  StageResult s,
  AppLocalizations l10n,
) {
  final i = result.inputs;
  final q = fmt(s.heatRate);
  final r = fmt(s.resistance);
  final dt = fmt(s.deltaT);
  final length = fmtInput(i.length);
  switch (s.stage) {
    case HeatStage.innerConvection:
      final area = fmt(s.area!);
      final h = fmtInput(i.hInner);
      return [
        (
          l10n.stepInnerArea,
          'A_i = 2π · r_1 · L = 2π · ${fmt(i.r1)} m · $length m = $area m²',
        ),
        (
          l10n.stepThermalResistance,
          'R_{conv,i} = 1 / (h_i · A_i) = 1 / ($h · $area) = $r K/W',
        ),
        (
          l10n.stepInnerHeatFlow,
          'Q = h_i · A_i · (T_f − T_1) = $h · $area · $dt K = $q W',
        ),
        (
          l10n.stepInnerWallTemperature,
          'T_1 = T_f − Q · R_{conv,i} = ${fmtTemp(s.tIn)} − $dt = ${fmtTemp(s.tOut)} °C',
        ),
      ];
    case HeatStage.pipeConduction:
      final k = fmtInput(i.kPipe);
      return [
        (
          l10n.stepIntegratedWall,
          'Q = 2π · k_p · L · (T_1 − T_2) / ln(r_2 / r_1)',
        ),
        (
          l10n.stepThermalResistance,
          'R_{pipe} = ln(r_2 / r_1) / (2π · k_p · L) = '
              'ln(${fmt(i.r2 * 1000)} / ${fmt(i.r1 * 1000)}) / '
              '(2π · $k · $length) = $r K/W',
        ),
        (
          l10n.stepWallHeatFlow,
          'Q = (T_1 − T_2) / R_{pipe} = $dt K / $r K/W = $q W',
        ),
        (
          l10n.stepOuterPipeTemperature,
          'T_2 = T_1 − Q · R_{pipe} = ${fmtTemp(s.tIn)} − $dt = ${fmtTemp(s.tOut)} °C',
        ),
      ];
    case HeatStage.insulationConduction:
      final k = fmtInput(i.kInsulation);
      return [
        (
          l10n.stepIntegratedLayer,
          'Q = 2π · k_{ins} · L · (T_2 − T_s) / ln(r_3 / r_2)',
        ),
        (
          l10n.stepThermalResistance,
          'R_{ins} = ln(r_3 / r_2) / (2π · k_{ins} · L) = '
              'ln(${fmt(i.r3 * 1000)} / ${fmt(i.r2 * 1000)}) / '
              '(2π · $k · $length) = $r K/W',
        ),
        (
          l10n.stepInsulationHeatFlow,
          'Q = (T_2 − T_s) / R_{ins} = $dt K / $r K/W = $q W',
        ),
        (
          l10n.stepSurfaceTemperature,
          'T_s = T_2 − Q · R_{ins} = ${fmtTemp(s.tIn)} − $dt = ${fmtTemp(s.tOut)} °C',
        ),
      ];
    case HeatStage.outerConvection:
      final area = fmt(s.area!);
      final h = fmtInput(i.hOuter);
      return [
        (
          l10n.stepOuterArea,
          'A_o = 2π · r_3 · L = 2π · ${fmt(i.r3)} m · $length m = $area m²',
        ),
        (
          l10n.stepThermalResistance,
          'R_{conv,o} = 1 / (h_o · A_o) = 1 / ($h · $area) = $r K/W',
        ),
        (
          l10n.stepConvectionHeatFlow,
          'Q_{conv} = h_o · A_o · (T_s − T_∞) = '
              '$h · $area · (${fmtTemp(s.tIn)} − ${fmtTemp(s.tOut)}) = $q W',
        ),
      ];
    case HeatStage.outerRadiation:
      final area = fmt(s.area!);
      final eps = fmtInput(i.emissivity);
      final tsK = fmtFixed(s.tIn + kelvinOffset, 2);
      final tInfK = fmtFixed(s.tOut + kelvinOffset, 2);
      final offset = fmtFixed(kelvinOffset, 2);
      return [
        (
          l10n.stepAbsoluteTemperatures,
          'T_s = ${fmtTemp(s.tIn)} + $offset = $tsK K\n'
              'T_∞ = ${fmtTemp(s.tOut)} + $offset = $tInfK K',
        ),
        (
          l10n.stepRadiatedHeat,
          'Q_{rad} = ε · σ · A_o · (T_s^4 − T_∞^4) = '
              '$eps · ${fmt(stefanBoltzmann)} · $area · '
              '($tsK^4 − $tInfK^4) = $q W',
        ),
        (
          l10n.stepLinearisedCoefficient,
          'h_{rad} = ε · σ · (T_s^2 + T_∞^2) · (T_s + T_∞) = '
              '${fmt(s.coefficient!)} W/m²·K',
        ),
        (
          l10n.stepEquivalentResistance,
          'R_{rad} = 1 / (h_{rad} · A_o) = $r K/W',
        ),
      ];
  }
}

String _lawFormula(HeatStage stage) => switch (stage) {
  HeatStage.innerConvection ||
  HeatStage.outerConvection => 'Q = h · A · (T_s − T_∞)',
  HeatStage.pipeConduction ||
  HeatStage.insulationConduction => 'Q = −k · A · dT/dr',
  HeatStage.outerRadiation => 'Q = ε · σ · A · (T_s^4 − T_{sur}^4)',
};
