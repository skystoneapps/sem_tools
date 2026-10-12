import 'package:flutter/material.dart';

import '../../common/ui/number_field.dart';
import '../../common/ui/number_format.dart';
import '../../common/ui/stat_tiles.dart';
import '../../common/ui/tex_formula.dart';
import '../../heat_transfer/domain/heat_model.dart';
import '../../heat_transfer/ui/heat_transfer_controller.dart';
import '../../l10n/app_localizations.dart';
import '../domain/price_model.dart';
import 'price_controller.dart';

/// Euro in TeX formulas, after a thin space. Written as the ISO code: the
/// math fonts have no € glyph.
const _texEuro = r'\,\mathrm{EUR}';

/// Cost of a heat loss over a usage period: the variables and results on the
/// left, the worked calculation on the right.
class PriceScreen extends StatelessWidget {
  const PriceScreen({
    super.key,
    required this.controller,
    required this.heatTransfer,
  });

  final PriceController controller;
  final HeatTransferController heatTransfer;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, heatTransfer]),
      builder: (context, _) {
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context);
        final result = calculatePrice(controller.inputs);

        final variables = _VariablesCard(
          controller: controller,
          heatTransfer: heatTransfer,
        );
        final results = _Results(
          result: result,
          tubeLength: controller.tubeLength,
        );
        final derivation = _PriceDerivation(
          result: result,
          tubeLength: controller.tubeLength,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 900) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  variables,
                  results,
                  const SizedBox(height: 24),
                  Text(l10n.calculation, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  derivation,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    children: [variables, results],
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
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      children: [
                        Text(
                          l10n.calculation,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        derivation,
                      ],
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

class _VariablesCard extends StatelessWidget {
  const _VariablesCard({required this.controller, required this.heatTransfer});

  final PriceController controller;
  final HeatTransferController heatTransfer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final inputs = controller.inputs;
    final heat = calculateHeatTransfer(heatTransfer.inputs);
    final heatLoss = (heat.heatRate.abs() * 100).roundToDouble() / 100;
    final tubeLength = controller.tubeLength;

    final fields = [
      NumberField(
        symbol: 'P',
        label: l10n.priceFieldPower,
        unit: 'W',
        value: inputs.power,
        min: 0,
        minInclusive: true,
        onChanged: (v) => controller.inputs = inputs.copyWith(power: v),
      ),
      NumberField(
        symbol: 't',
        label: l10n.priceFieldDuration,
        unit: 'h',
        value: inputs.duration,
        min: 0,
        minInclusive: true,
        presets: [
          (l10n.presetDay, 24),
          (l10n.presetWeek, 168),
          (l10n.presetMonth, 730),
          (l10n.presetYear, 8760),
        ],
        onChanged: (v) => controller.inputs = inputs.copyWith(duration: v),
      ),
      NumberField(
        symbol: 'p',
        label: l10n.priceFieldMarketPrice,
        unit: '€/MWh',
        value: inputs.marketPrice,
        min: 0,
        minInclusive: true,
        onChanged: (v) => controller.inputs = inputs.copyWith(marketPrice: v),
      ),
    ];

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
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                final columns = (constraints.maxWidth / 200).floor().clamp(
                  1,
                  3,
                );
                final width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final field in fields)
                      SizedBox(width: width, child: field),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => controller.importHeatLoss(
                heatLoss,
                heatTransfer.inputs.length,
              ),
              icon: const Icon(Icons.thermostat),
              label: Text(
                l10n.priceUseHeatLoss(
                  fmtValue(heatLoss),
                  fmtInput(heatTransfer.inputs.length),
                ),
              ),
            ),
            if (tubeLength != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.link,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.priceFromHeatTransfer(fmtInput(tubeLength)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
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

class _Results extends StatelessWidget {
  const _Results({required this.result, required this.tubeLength});

  final PriceResult result;
  final double? tubeLength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final length = tubeLength;
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
        StatRow([
          (l10n.statCost, fmtCurrency(result.cost)),
          (l10n.statEnergy, '${fmt(result.energyMegawattHours)} MWh'),
          (
            l10n.statCostPerHour,
            '${fmtCurrency(result.costPerHour, decimals: 4)}/h',
          ),
          if (length != null && length > 0)
            (l10n.statCostPerMetre, '${fmtCurrency(result.cost / length)}/m'),
        ]),
      ],
    );
  }
}

class _PriceDerivation extends StatelessWidget {
  const _PriceDerivation({required this.result, required this.tubeLength});

  final PriceResult result;
  final double? tubeLength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final inputs = result.inputs;
    final power = texInput(inputs.power);
    final duration = texInput(inputs.duration);
    final price = texInput(inputs.marketPrice);
    final wattHours = texNum(result.energyWattHours);
    final megawattHours = texNum(result.energyMegawattHours);
    final cost = texValue(result.cost);
    final length = tubeLength;

    return Derivation(
      color: theme.colorScheme.tertiary,
      law: l10n.lawEnergyCost,
      formula: r'C = \frac{P\,t}{10^6}\,p',
      steps: [
        (
          l10n.priceStepEnergy,
          'E = P\\,t = $power\\,\\mathrm{W} \\cdot $duration\\,\\mathrm{h} = '
              '$wattHours\\,\\mathrm{Wh}',
        ),
        (
          l10n.priceStepConvert,
          'E = \\frac{$wattHours\\,\\mathrm{Wh}}{10^6\\,\\mathrm{Wh/MWh}} = '
              '$megawattHours\\,\\mathrm{MWh}',
        ),
        (
          l10n.priceStepCost,
          'C = E\\,p = $megawattHours\\,\\mathrm{MWh} \\cdot '
              '$price$_texEuro/\\mathrm{MWh} = $cost$_texEuro',
        ),
        (
          l10n.priceStepCostPerHour,
          '\\frac{C}{t} = \\frac{P\\,p}{10^6} = '
              '\\frac{$power \\cdot $price}{10^6} = '
              '${texNum(result.costPerHour)}$_texEuro/\\mathrm{h}',
        ),
        if (length != null && length > 0)
          (
            l10n.priceStepCostPerMetre,
            '\\frac{C}{L} = \\frac{$cost}{${texInput(length)}} = '
                '${texValue(result.cost / length)}$_texEuro/\\mathrm{m}',
          ),
      ],
      legend: [
        ('P', l10n.symbolPower, 'W'),
        ('t', l10n.symbolDuration, 'h'),
        ('p', l10n.symbolMarketPrice, '€/MWh'),
        ('E', l10n.symbolEnergy, 'MWh'),
        ('C', l10n.symbolCost, '€'),
        if (length != null) ('L', l10n.symbolLength, 'm'),
      ],
    );
  }
}
