import 'package:flutter/material.dart';

import '../../common/ui/number_field.dart';
import '../../common/ui/number_format.dart';
import '../../common/ui/stat_tiles.dart';
import '../../common/ui/tex_formula.dart';
import '../../heat_transfer/ui/heat_palette.dart';
import '../../heat_transfer/ui/heat_transfer_controller.dart';
import '../../l10n/app_localizations.dart';
import '../domain/expansion_model.dart';
import 'expansion_controller.dart';
import 'vessel_painter.dart';

const _texLitre = r'\,\mathrm{L}';
const _texCubicMetre = r'\,\mathrm{m^3}';
const _texKilogram = r'\,\mathrm{kg}';
const _texDensity = r'\,\mathrm{kg/m^3}';

/// Liquid thermal expansion in a heat network: the visual comparison,
/// variables and results on the left, the worked calculation on the right.
class ExpansionScreen extends StatelessWidget {
  const ExpansionScreen({
    super.key,
    required this.controller,
    required this.heatTransfer,
  });

  final ExpansionController controller;
  final HeatTransferController heatTransfer;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, heatTransfer]),
      builder: (context, _) {
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context);
        final result = calculateExpansion(controller.inputs);

        final diagram = _VesselView(result: result);
        final variables = _VariablesCard(
          controller: controller,
          heatTransfer: heatTransfer,
        );
        final results = _Results(result: result);
        final derivation = _ExpansionDerivation(result: result);

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
                  derivation,
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

class _VesselView extends StatelessWidget {
  const _VesselView({required this.result});

  final ExpansionResult result;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: VesselPainter(
            result: result,
            palette: HeatPalette.of(context),
            colorScheme: Theme.of(context).colorScheme,
            l10n: AppLocalizations.of(context),
            textStyle: DefaultTextStyle.of(context).style.copyWith(
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _VariablesCard extends StatelessWidget {
  const _VariablesCard({
    required this.controller,
    required this.heatTransfer,
  });

  final ExpansionController controller;
  final HeatTransferController heatTransfer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final inputs = controller.inputs;
    final tubeInputs = heatTransfer.inputs;

    final densityPresets = <(String, double)>[
      (l10n.presetWater10, 999.7),
      (l10n.presetWater20, 998.2),
      (l10n.presetWater40, 992.2),
      (l10n.presetWater60, 983.2),
      (l10n.presetWater80, 971.8),
      (l10n.presetWater90, 965.3),
      (l10n.presetWater110, 950.6),
      (l10n.presetWater150, 917.0),
    ];

    final volumeFields = inputs.useTubeGeometry
        ? [
            NumberField(
              key: const ValueKey('innerDiameter'),
              symbol: 'Dᵢ',
              label: l10n.fieldInnerDiameter,
              unit: 'mm',
              value: inputs.innerDiameter,
              min: 0,
              onChanged: (v) =>
                  controller.inputs = inputs.copyWith(innerDiameter: v),
            ),
            NumberField(
              key: const ValueKey('length'),
              symbol: 'L',
              label: l10n.fieldLength,
              unit: 'm',
              value: inputs.length,
              min: 0,
              onChanged: (v) => controller.inputs = inputs.copyWith(length: v),
            ),
          ]
        : [
            NumberField(
              key: const ValueKey('volume'),
              symbol: 'V₀',
              label: l10n.expansionFieldVolume,
              unit: 'm³',
              value: inputs.volume,
              min: 0,
              onChanged: (v) => controller.inputs = inputs.copyWith(volume: v),
            ),
          ];

    final densityFields = [
      NumberField(
        symbol: 'ρ₁',
        label: l10n.expansionFieldDensityCold,
        unit: 'kg/m³',
        value: inputs.densityCold,
        min: 0,
        presets: densityPresets,
        onChanged: (v) => controller.inputs = inputs.copyWith(densityCold: v),
      ),
      NumberField(
        symbol: 'ρ₂',
        label: l10n.expansionFieldDensityHot,
        unit: 'kg/m³',
        value: inputs.densityHot,
        min: 0,
        presets: densityPresets,
        onChanged: (v) => controller.inputs = inputs.copyWith(densityHot: v),
      ),
    ];

    Widget buildGrid(List<Widget> fields) {
      return LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 12.0;
          final columns = (constraints.maxWidth / 200)
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
                l10n.expansionSectionVolume,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.water_drop_outlined),
                  label: Text(l10n.expansionModeVolume),
                ),
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.straighten),
                  label: Text(l10n.expansionModeTube),
                ),
              ],
              selected: {inputs.useTubeGeometry},
              onSelectionChanged: (selected) {
                controller.inputs = inputs.copyWith(
                  useTubeGeometry: selected.first,
                );
              },
            ),
            const SizedBox(height: 12),
            buildGrid(volumeFields),
            if (inputs.useTubeGeometry) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => controller.importTube(
                  innerDiameterMm: tubeInputs.innerDiameter,
                  lengthM: tubeInputs.length,
                ),
                icon: const Icon(Icons.thermostat),
                label: Text(
                  l10n.expansionUseHeatTransferTube(
                    fmtInput(tubeInputs.innerDiameter),
                    fmtInput(tubeInputs.length),
                  ),
                ),
              ),
              if (controller.fromHeatTransfer) ...[
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
                        l10n.expansionFromHeatTransfer(
                          fmtInput(inputs.innerDiameter),
                          fmtInput(inputs.length),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                l10n.expansionSectionDensity,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            buildGrid(densityFields),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.result});

  final ExpansionResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
          (l10n.statExpansionVolume, '${fmtValue(result.expansionLitres)} L'),
          (l10n.statInitialVolume, '${fmtValue(result.initialLitres)} L'),
          (l10n.statFinalVolume, '${fmtValue(result.finalLitres)} L'),
          (l10n.statMass, '${fmtValue(result.mass)} kg'),
        ]),
        if (!result.densityValid) ...[
          const SizedBox(height: 12),
          _WarningBanner(message: l10n.expansionInvalidDensity),
        ],
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: scheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpansionDerivation extends StatelessWidget {
  const _ExpansionDerivation({required this.result});

  final ExpansionResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final inputs = result.inputs;

    final diMm = texInput(inputs.innerDiameter);
    final r1M = texNum(inputs.innerRadius);
    final lenM = texInput(inputs.length);
    final v0 = inputs.useTubeGeometry
        ? texNum(result.initialVolume)
        : texInput(inputs.volume);
    final rho1 = texInput(inputs.densityCold);
    final rho2 = texInput(inputs.densityHot);
    final mass = texNum(result.mass);
    final v2 = texNum(result.finalVolume);
    final dvM3 = texNum(result.expansionVolume);
    final dvL = texValue(result.expansionLitres);

    return Derivation(
      color: theme.colorScheme.primary,
      law: l10n.lawConservationOfMass,
      formula:
          r'm = \rho_1\,V_0 = \rho_2\,V_2 \implies '
          r'\Delta V = V_0\left(\frac{\rho_1}{\rho_2} - 1\right)',
      steps: [
        if (inputs.useTubeGeometry) ...[
          (
            l10n.expansionStepRadius,
            'r_1 = \\frac{D_i}{2} = \\frac{$diMm\\,\\mathrm{mm}}{2} = '
                '$r1M$texMetre',
          ),
          (
            l10n.expansionStepTubeVolume,
            'V_0 = \\pi\\,r_1^2\\,L = \\pi \\cdot ($r1M$texMetre)^2 \\cdot '
                '$lenM$texMetre = $v0$_texCubicMetre',
          ),
        ],
        (
          l10n.expansionStepMass,
          'm = \\rho_1\\,V_0 = $rho1$_texDensity \\cdot $v0$_texCubicMetre = '
              '$mass$_texKilogram',
        ),
        (
          l10n.expansionStepFinalVolume,
          'V_2 = \\frac{m}{\\rho_2} = '
              '\\frac{$mass$_texKilogram}{$rho2$_texDensity} = '
              '$v2$_texCubicMetre',
        ),
        (
          l10n.expansionStepDeltaV,
          '\\Delta V = V_2 - V_0 = '
              '$v2$_texCubicMetre - $v0$_texCubicMetre = '
              '$dvM3$_texCubicMetre',
        ),
        (
          l10n.expansionStepConvertLitres,
          '\\Delta V = $dvM3$_texCubicMetre \\cdot 1000\\,\\mathrm{L/m^3} = '
              '$dvL$_texLitre',
        ),
      ],
      legend: [
        if (inputs.useTubeGeometry) ...[
          ('D_i', l10n.fieldInnerDiameter, 'mm'),
          ('r_1', l10n.symbolRadiusInner, 'm'),
          ('L', l10n.symbolLength, 'm'),
        ],
        ('V_0', l10n.symbolInitialVolume, 'm³'),
        ('V_2', l10n.symbolFinalVolume, 'm³'),
        (r'\Delta V', l10n.symbolExpansionVolume, 'm³, L'),
        (r'\rho_1', l10n.symbolDensityCold, 'kg/m³'),
        (r'\rho_2', l10n.symbolDensityHot, 'kg/m³'),
        ('m', l10n.symbolMass, 'kg'),
      ],
    );
  }
}
