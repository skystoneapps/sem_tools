import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'formula_text.dart';
import 'heat_labels.dart';
import 'heat_model.dart';
import 'heat_palette.dart';
import 'results_panel.dart';
import 'stat_tiles.dart';
import 'symbol_glossary.dart';
import 'tex_formula.dart';

/// Right-hand pane: a picker for the stage to inspect, followed by that
/// stage's step-by-step calculation. A `null` selection shows how the stages
/// combine into the total.
class DetailsPane extends StatelessWidget {
  const DetailsPane({
    super.key,
    required this.result,
    required this.selected,
    required this.onSelected,
    required this.onIncludeRadiationChanged,
  });

  final HeatTransferResult result;
  final HeatStage? selected;
  final ValueChanged<HeatStage?> onSelected;
  final ValueChanged<bool> onIncludeRadiationChanged;

  @override
  Widget build(BuildContext context) {
    final stage = selected;
    final radiationIgnored =
        stage == HeatStage.outerRadiation && !result.inputs.includeRadiation;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _StagePicker(selected: stage, onSelected: onSelected),
        const SizedBox(height: 20),
        if (stage == null)
          _TotalDetails(result: result)
        else if (radiationIgnored)
          _RadiationIgnored(onIncludeRadiationChanged)
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

/// A worked step: an explanation and a TeX formula.
typedef _Step = (String, String);

/// The law box, the worked steps and the "where:" list of symbols.
class _Derivation extends StatelessWidget {
  const _Derivation({
    required this.color,
    required this.law,
    required this.formula,
    required this.steps,
    required this.symbols,
  });

  final Color color;
  final String law;

  /// The governing equation, in TeX.
  final String formula;
  final List<_Step> steps;
  final List<Sym> symbols;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
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
              const SizedBox(height: 8),
              TexFormula(formula, style: theme.textTheme.titleLarge),
            ],
          ),
        ),
        for (final (index, (label, formula)) in steps.indexed)
          Padding(
            padding: const EdgeInsets.only(top: 18),
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
                      const SizedBox(height: 6),
                      TexFormula(formula, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 12),
        SymbolLegend(symbols: symbols),
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
        StatRow([
          (l10n.statHeatFlow, '${fmtValue(stage.heatRate)} W'),
          (l10n.statResistance, '${fmt(stage.resistance)} K/W'),
          (l10n.statTemperatureDrop, '${fmt(stage.deltaT)} K'),
        ]),
        const SizedBox(height: 8),
        Text(
          '${fmtTemp(stage.tIn)} °C → ${fmtTemp(stage.tOut)} °C',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        _Derivation(
          color: palette.mechanism(stage.stage.mechanism),
          law: stage.stage.mechanism.law(l10n),
          formula: _lawFormula(stage.stage, _fluidTex(result)),
          steps: _stepsFor(result, stage, l10n),
          symbols: _symbolsFor(stage.stage, result.simplified),
        ),
        if (outer) ...[
          const SizedBox(height: 16),
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

/// Shown instead of the radiation derivation while radiation is ignored.
class _RadiationIgnored extends StatelessWidget {
  const _RadiationIgnored(this.onIncludeRadiationChanged);

  final ValueChanged<bool> onIncludeRadiationChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context).radiationIgnored,
              style: TextStyle(color: scheme.onSecondaryContainer),
            ),
          ),
          RadiationToggle(
            included: false,
            onChanged: onIncludeRadiationChanged,
          ),
        ],
      ),
    );
  }
}

/// How the stages combine into the total heat flow, and how the fluid
/// temperature changes along the tube.
class _TotalDetails extends StatelessWidget {
  const _TotalDetails({required this.result});

  final HeatTransferResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final i = result.inputs;
    final conv = result[HeatStage.outerConvection];
    final rad = result[HeatStage.outerRadiation];
    final series = [
      result[HeatStage.innerConvection],
      result[HeatStage.pipeConduction],
      result[HeatStage.insulationConduction],
    ].map((s) => texNum(s.resistance)).join(' + ');
    final sumR = texNum(result.totalResistance);
    final tIn = texTemp(result.inletTemp);
    final tInf = _paren(result.ambientTemp, texTemp);
    final tOut = texTemp(result.outletTemp);
    final tMean = texTemp(result.meanFluidTemp);
    final mDot = texInput(i.massFlow);
    final cp = texInput(i.specificHeat);
    final q = texValue(result.heatRate);
    final check =
        (result.meanFluidTemp - result.ambientTemp) / result.totalResistance;

    final resistanceSteps = <_Step>[
      if (!i.includeRadiation)
        (
          l10n.stepOnlyConvection,
          'R_{\\mathrm{out}} = R_{\\mathrm{conv,o}} = '
              '${texNum(result.outerResistance)}$texResistance',
        )
      else
        (
          l10n.stepParallel,
          'R_{\\mathrm{out}} = \\left(\\frac{1}{R_{\\mathrm{conv,o}}} + '
              '\\frac{1}{R_{\\mathrm{rad}}}\\right)^{-1} = '
              '\\left(\\frac{1}{${texNum(conv.resistance)}} + '
              '\\frac{1}{${texNum(rad.resistance)}}\\right)^{-1} = '
              '${texNum(result.outerResistance)}$texResistance',
        ),
      (
        l10n.stepSeries,
        '\\Sigma R = R_{\\mathrm{conv,i}} + R_{\\mathrm{pipe}} + '
            'R_{\\mathrm{ins}} + R_{\\mathrm{out}} = $series + '
            '${texNum(result.outerResistance)} = $sumR$texResistance',
      ),
    ];
    final perMetre = (
      l10n.stepHeatFlowPerMetre,
      "q' = \\frac{Q}{L} = \\frac{$q}{${texInput(i.length)}} = "
          '${texValue(result.heatRatePerMetre)}$texWattPerMetre',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatRow([
          (l10n.statHeatFlow, '${fmtValue(result.heatRate)} W'),
          (l10n.statOutletTemperature, '${fmtTemp(result.outletTemp)} °C'),
          (l10n.statTotalResistance, '${fmt(result.totalResistance)} K/W'),
        ]),
        const SizedBox(height: 20),
        if (result.simplified)
          _Derivation(
            color: theme.colorScheme.primary,
            law: l10n.lawSeries,
            formula: r'Q = \frac{T_{\mathrm{in}} - T_\infty}{\Sigma R}',
            steps: [
              ...resistanceSteps,
              (
                l10n.stepConstantFluid,
                'Q = \\frac{T_{\\mathrm{in}} - T_\\infty}{\\Sigma R} = '
                    '\\frac{$tIn - $tInf}{$sumR} = $q$texWatt',
              ),
              (
                l10n.stepOutletEnergyBalance,
                'T_{\\mathrm{out}} = T_{\\mathrm{in}} - '
                    '\\frac{Q}{\\dot{m}\\,c_p} = $tIn - '
                    '\\frac{$q}{$mDot \\cdot $cp} = $tOut$texCelsius',
              ),
              perMetre,
            ],
            symbols: const [
              Sym.heatFlow,
              Sym.inletTemp,
              Sym.ambientTemp,
              Sym.resistanceTotal,
              Sym.resistanceOuter,
              Sym.outletTemp,
              Sym.massFlow,
              Sym.specificHeat,
              Sym.heatFlowPerMetre,
              Sym.length,
            ],
          )
        else
          _Derivation(
            color: theme.colorScheme.primary,
            law: l10n.lawEnergyBalance,
            formula: r'Q = \dot{m}\,c_p\,(T_{\mathrm{in}} - T_{\mathrm{out}})',
            steps: [
              ...resistanceSteps,
              (
                l10n.stepOutletTemperature,
                'T_{\\mathrm{out}} = T_\\infty + (T_{\\mathrm{in}} - T_\\infty)'
                    '\\exp\\left(-\\frac{1}{\\Sigma R\\,\\dot{m}\\,c_p}\\right) = '
                    '${texTemp(result.ambientTemp)} + ($tIn - $tInf)'
                    '\\exp\\left(-\\frac{1}{$sumR \\cdot $mDot \\cdot $cp}\\right)'
                    ' = $tOut$texCelsius',
              ),
              (
                l10n.stepTotalHeatFlow,
                'Q = \\dot{m}\\,c_p\\,(T_{\\mathrm{in}} - T_{\\mathrm{out}}) = '
                    '$mDot \\cdot $cp \\cdot '
                    '${_paren(result.inletTemp - result.outletTemp, texNum)}'
                    '$texKelvin = $q$texWatt',
              ),
              (
                l10n.stepMeanTemperature,
                'T_m = T_\\infty + \\frac{T_{\\mathrm{in}} - T_{\\mathrm{out}}}'
                    '{\\ln\\left[(T_{\\mathrm{in}} - T_\\infty)/'
                    '(T_{\\mathrm{out}} - T_\\infty)\\right]} = '
                    '$tMean$texCelsius',
              ),
              (
                l10n.stepCheck,
                'Q = \\frac{T_m - T_\\infty}{\\Sigma R} = '
                    '\\frac{$tMean - $tInf}{$sumR} = ${texValue(check)}$texWatt',
              ),
              perMetre,
            ],
            symbols: const [
              Sym.heatFlow,
              Sym.massFlow,
              Sym.specificHeat,
              Sym.inletTemp,
              Sym.outletTemp,
              Sym.meanFluidTemp,
              Sym.ambientTemp,
              Sym.resistanceTotal,
              Sym.resistanceOuter,
              Sym.heatFlowPerMetre,
              Sym.length,
            ],
          ),
        if (result.simplified) ...[
          const SizedBox(height: 16),
          _SimplificationNote(result: result),
        ],
      ],
    );
  }
}

/// How far the simplified heat flow is from the exact one, or a warning when
/// the simplification does not hold.
class _SimplificationNote extends StatelessWidget {
  const _SimplificationNote({required this.result});

  final HeatTransferResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final valid = result.simplificationValid;
    final exact = result.exactHeatRate!;
    final difference = result.heatRate - exact;
    final percent = exact == 0 ? 0.0 : difference / exact * 100;
    String signed(double v) => v > 0 ? '+${fmtValue(v)}' : fmtValue(v);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: valid ? scheme.secondaryContainer : scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            valid ? Icons.info_outline : Icons.warning_amber_rounded,
            size: 20,
            color: valid
                ? scheme.onSecondaryContainer
                : scheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              valid
                  ? l10n.simplificationComparison(
                      fmtValue(exact),
                      signed(difference),
                      signed(percent),
                    )
                  : l10n.simplificationInvalid,
              style: TextStyle(
                color: valid
                    ? scheme.onSecondaryContainer
                    : scheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// [format]s [value], in parentheses when negative so it can follow an
/// operator.
String _paren(double value, String Function(double) format) =>
    value < 0 ? '(${format(value)})' : format(value);

/// TeX symbol of the fluid temperature the stages are evaluated at.
String _fluidTex(HeatTransferResult result) =>
    result.simplified ? r'T_{\mathrm{in}}' : 'T_m';

String _lawFormula(HeatStage stage, String fluid) => switch (stage) {
  HeatStage.innerConvection => 'Q = h_i\\,A_i\\,($fluid - T_1)',
  HeatStage.pipeConduction =>
    r'Q = -k_p\,(2\pi r L)\,\frac{\mathrm{d}T}{\mathrm{d}r}',
  HeatStage.insulationConduction =>
    r'Q = -k_{\mathrm{ins}}\,(2\pi r L)\,\frac{\mathrm{d}T}{\mathrm{d}r}',
  HeatStage.outerConvection =>
    r'Q_{\mathrm{conv}} = h_o\,A_o\,(T_s - T_\infty)',
  HeatStage.outerRadiation =>
    r'Q_{\mathrm{rad}} = \varepsilon\,\sigma\,A_o\,(T_s^4 - T_\infty^4)',
};

List<Sym> _symbolsFor(HeatStage stage, bool simplified) => switch (stage) {
  HeatStage.innerConvection => [
    Sym.heatFlow,
    Sym.hInner,
    Sym.areaInner,
    simplified ? Sym.inletTemp : Sym.meanFluidTemp,
    Sym.innerWallTemp,
    Sym.radiusInner,
    Sym.length,
    Sym.resistanceInnerConvection,
  ],
  HeatStage.pipeConduction => const [
    Sym.heatFlow,
    Sym.kPipe,
    Sym.radius,
    Sym.length,
    Sym.gradient,
    Sym.radiusInner,
    Sym.radiusPipe,
    Sym.innerWallTemp,
    Sym.interfaceTemp,
    Sym.resistancePipe,
  ],
  HeatStage.insulationConduction => const [
    Sym.heatFlow,
    Sym.kInsulation,
    Sym.radius,
    Sym.length,
    Sym.gradient,
    Sym.radiusPipe,
    Sym.radiusOuter,
    Sym.interfaceTemp,
    Sym.surfaceTemp,
    Sym.resistanceInsulation,
  ],
  HeatStage.outerConvection => const [
    Sym.heatFlowConvection,
    Sym.hOuter,
    Sym.areaOuter,
    Sym.surfaceTemp,
    Sym.ambientTemp,
    Sym.radiusOuter,
    Sym.length,
    Sym.resistanceOuterConvection,
  ],
  HeatStage.outerRadiation => const [
    Sym.heatFlowRadiation,
    Sym.emissivity,
    Sym.stefanBoltzmann,
    Sym.areaOuter,
    Sym.surfaceTemp,
    Sym.ambientTemp,
    Sym.hRadiation,
    Sym.resistanceRadiation,
  ],
};

List<_Step> _stepsFor(
  HeatTransferResult result,
  StageResult s,
  AppLocalizations l10n,
) {
  final i = result.inputs;
  final q = texValue(s.heatRate);
  final r = texNum(s.resistance);
  final dt = _paren(s.deltaT, texNum);
  final tIn = texTemp(s.tIn);
  final tOut = _paren(s.tOut, texTemp);
  final length = texInput(i.length);
  switch (s.stage) {
    case HeatStage.innerConvection:
      final fluid = _fluidTex(result);
      final area = texValue(s.area!);
      final h = texInput(i.hInner);
      return [
        (
          l10n.stepInnerArea,
          'A_i = 2\\pi\\, r_1 L = 2\\pi \\cdot ${texNum(i.r1)}$texMetre '
              '\\cdot $length$texMetre = $area$texSquareMetre',
        ),
        (
          l10n.stepThermalResistance,
          'R_{\\mathrm{conv,i}} = \\frac{1}{h_i A_i} = '
              '\\frac{1}{$h \\cdot $area} = $r$texResistance',
        ),
        (
          l10n.stepInnerHeatFlow,
          'Q = h_i A_i\\,($fluid - T_1) = $h \\cdot $area \\cdot '
              '$dt$texKelvin = $q$texWatt',
        ),
        (
          l10n.stepInnerWallTemperature,
          'T_1 = $fluid - Q\\,R_{\\mathrm{conv,i}} = $tIn - $dt = '
              '${texTemp(s.tOut)}$texCelsius',
        ),
      ];
    case HeatStage.pipeConduction:
      return [
        (
          l10n.stepIntegratedWall,
          'Q = \\frac{2\\pi\\, k_p L\\,(T_1 - T_2)}{\\ln(r_2/r_1)}',
        ),
        (
          l10n.stepThermalResistance,
          'R_{\\mathrm{pipe}} = \\frac{\\ln(r_2/r_1)}{2\\pi\\, k_p L} = '
              '\\frac{\\ln(${texNum(i.r2 * 1000)}/${texNum(i.r1 * 1000)})}'
              '{2\\pi \\cdot ${texInput(i.kPipe)} \\cdot $length} = '
              '$r$texResistance',
        ),
        (
          l10n.stepWallHeatFlow,
          'Q = \\frac{T_1 - T_2}{R_{\\mathrm{pipe}}} = '
              '\\frac{$dt$texKelvin}{$r$texResistance} = $q$texWatt',
        ),
        (
          l10n.stepOuterPipeTemperature,
          'T_2 = T_1 - Q\\,R_{\\mathrm{pipe}} = $tIn - $dt = '
              '${texTemp(s.tOut)}$texCelsius',
        ),
      ];
    case HeatStage.insulationConduction:
      return [
        (
          l10n.stepIntegratedLayer,
          'Q = \\frac{2\\pi\\, k_{\\mathrm{ins}} L\\,(T_2 - T_s)}'
              '{\\ln(r_3/r_2)}',
        ),
        (
          l10n.stepThermalResistance,
          'R_{\\mathrm{ins}} = \\frac{\\ln(r_3/r_2)}'
              '{2\\pi\\, k_{\\mathrm{ins}} L} = '
              '\\frac{\\ln(${texNum(i.r3 * 1000)}/${texNum(i.r2 * 1000)})}'
              '{2\\pi \\cdot ${texInput(i.kInsulation)} \\cdot $length} = '
              '$r$texResistance',
        ),
        (
          l10n.stepInsulationHeatFlow,
          'Q = \\frac{T_2 - T_s}{R_{\\mathrm{ins}}} = '
              '\\frac{$dt$texKelvin}{$r$texResistance} = $q$texWatt',
        ),
        (
          l10n.stepSurfaceTemperature,
          'T_s = T_2 - Q\\,R_{\\mathrm{ins}} = $tIn - $dt = '
              '${texTemp(s.tOut)}$texCelsius',
        ),
      ];
    case HeatStage.outerConvection:
      final area = texValue(s.area!);
      final h = texInput(i.hOuter);
      return [
        (
          l10n.stepOuterArea,
          'A_o = 2\\pi\\, r_3 L = 2\\pi \\cdot ${texNum(i.r3)}$texMetre '
              '\\cdot $length$texMetre = $area$texSquareMetre',
        ),
        (
          l10n.stepThermalResistance,
          'R_{\\mathrm{conv,o}} = \\frac{1}{h_o A_o} = '
              '\\frac{1}{$h \\cdot $area} = $r$texResistance',
        ),
        (
          l10n.stepConvectionHeatFlow,
          'Q_{\\mathrm{conv}} = h_o A_o\\,(T_s - T_\\infty) = '
              '$h \\cdot $area \\cdot ($tIn - $tOut) = $q$texWatt',
        ),
      ];
    case HeatStage.outerRadiation:
      final area = texValue(s.area!);
      final offset = texFixed(kelvinOffset, 2);
      final tsK = texTemp(s.tIn + kelvinOffset);
      final tInfK = texTemp(s.tOut + kelvinOffset);
      final hRad = texValue(s.coefficient!);
      return [
        (
          l10n.stepAbsoluteTemperatures,
          'T_s = $tIn + $offset = $tsK$texKelvin, \\qquad '
              'T_\\infty = ${texTemp(s.tOut)} + $offset = $tInfK$texKelvin',
        ),
        (
          l10n.stepRadiatedHeat,
          'Q_{\\mathrm{rad}} = \\varepsilon\\,\\sigma\\,A_o\\,'
              '(T_s^4 - T_\\infty^4) = ${texInput(i.emissivity)} \\cdot '
              '${texNum(stefanBoltzmann)} \\cdot $area \\cdot '
              '({$tsK}^4 - {$tInfK}^4) = $q$texWatt',
        ),
        (
          l10n.stepLinearisedCoefficient,
          'h_{\\mathrm{rad}} = \\varepsilon\\,\\sigma\\,(T_s^2 + T_\\infty^2)'
              '(T_s + T_\\infty) = $hRad$texHeatTransferCoefficient',
        ),
        (
          l10n.stepEquivalentResistance,
          'R_{\\mathrm{rad}} = \\frac{1}{h_{\\mathrm{rad}} A_o} = '
              '\\frac{1}{$hRad \\cdot $area} = $r$texResistance',
        ),
      ];
  }
}
