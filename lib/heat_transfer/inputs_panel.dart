import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'formula_text.dart';
import 'heat_model.dart';

/// Describes one editable variable of [TubeInputs].
class _Field {
  const _Field({
    required this.symbol,
    required this.label,
    required this.unit,
    required this.read,
    required this.write,
    this.min,
    this.minInclusive = false,
    this.max,
    this.presets = const [],
  });

  /// Symbol in [FormulaText] markup, e.g. `T_f`.
  final String symbol;
  final String Function(AppLocalizations) label;
  final String unit;
  final double Function(TubeInputs) read;
  final TubeInputs Function(TubeInputs, double) write;
  final double? min;
  final bool minInclusive;
  final double? max;
  final List<(String Function(AppLocalizations), double)> presets;

  String? validate(double? value, AppLocalizations l10n) {
    if (value == null || !value.isFinite) return l10n.errorEnterNumber;
    final lower = min;
    if (lower != null) {
      if (minInclusive ? value < lower : value <= lower) {
        return minInclusive
            ? l10n.errorAtLeast(fmtInput(lower))
            : l10n.errorGreaterThan(fmtInput(lower));
      }
    }
    final upper = max;
    if (upper != null && value > upper) {
      return l10n.errorAtMost(fmtInput(upper));
    }
    return null;
  }
}

final _sections = <(String Function(AppLocalizations), List<_Field>)>[
  (
    (l) => l.sectionTemperatures,
    [
      _Field(
        symbol: 'T_f',
        label: (l) => l.fieldFluidTemperature,
        unit: '°C',
        read: (i) => i.fluidTemp,
        write: (i, v) => i.copyWith(fluidTemp: v),
        min: -kelvinOffset,
      ),
      _Field(
        symbol: 'T_∞',
        label: (l) => l.fieldAmbientTemperature,
        unit: '°C',
        read: (i) => i.ambientTemp,
        write: (i, v) => i.copyWith(ambientTemp: v),
        min: -kelvinOffset,
      ),
    ],
  ),
  (
    (l) => l.sectionGeometry,
    [
      _Field(
        symbol: 'L',
        label: (l) => l.fieldLength,
        unit: 'm',
        read: (i) => i.length,
        write: (i, v) => i.copyWith(length: v),
        min: 0,
      ),
      _Field(
        symbol: 'D_i',
        label: (l) => l.fieldInnerDiameter,
        unit: 'mm',
        read: (i) => i.innerDiameter,
        write: (i, v) => i.copyWith(innerDiameter: v),
        min: 0,
      ),
      _Field(
        symbol: 't_w',
        label: (l) => l.fieldWallThickness,
        unit: 'mm',
        read: (i) => i.wallThickness,
        write: (i, v) => i.copyWith(wallThickness: v),
        min: 0,
        minInclusive: true,
      ),
      _Field(
        symbol: 't_{ins}',
        label: (l) => l.fieldInsulationThickness,
        unit: 'mm',
        read: (i) => i.insulationThickness,
        write: (i, v) => i.copyWith(insulationThickness: v),
        min: 0,
        minInclusive: true,
      ),
    ],
  ),
  (
    (l) => l.sectionMaterials,
    [
      _Field(
        symbol: 'k_p',
        label: (l) => l.fieldPipeConductivity,
        unit: 'W/m·K',
        read: (i) => i.kPipe,
        write: (i, v) => i.copyWith(kPipe: v),
        min: 0,
        presets: [
          ((l) => l.presetCarbonSteel, 45),
          ((l) => l.presetStainlessSteel, 16),
          ((l) => l.presetCopper, 385),
          ((l) => l.presetAluminium, 205),
          ((l) => l.presetPvc, 0.19),
        ],
      ),
      _Field(
        symbol: 'k_{ins}',
        label: (l) => l.fieldInsulationConductivity,
        unit: 'W/m·K',
        read: (i) => i.kInsulation,
        write: (i, v) => i.copyWith(kInsulation: v),
        min: 0,
        presets: [
          ((l) => l.presetMineralWool, 0.04),
          ((l) => l.presetPolyurethaneFoam, 0.025),
          ((l) => l.presetElastomericFoam, 0.036),
          ((l) => l.presetCalciumSilicate, 0.06),
          ((l) => l.presetAerogelBlanket, 0.015),
        ],
      ),
    ],
  ),
  (
    (l) => l.sectionSurfaces,
    [
      _Field(
        symbol: 'h_i',
        label: (l) => l.fieldInnerConvection,
        unit: 'W/m²·K',
        read: (i) => i.hInner,
        write: (i, v) => i.copyWith(hInner: v),
        min: 0,
        presets: [
          ((l) => l.presetGasForced, 50),
          ((l) => l.presetOilForced, 300),
          ((l) => l.presetWaterForced, 1000),
          ((l) => l.presetWaterTurbulent, 5000),
          ((l) => l.presetCondensingSteam, 10000),
        ],
      ),
      _Field(
        symbol: 'h_o',
        label: (l) => l.fieldOuterConvection,
        unit: 'W/m²·K',
        read: (i) => i.hOuter,
        write: (i, v) => i.copyWith(hOuter: v),
        min: 0,
        minInclusive: true,
        presets: [
          ((l) => l.presetStillAir, 5),
          ((l) => l.presetIndoorAir, 10),
          ((l) => l.presetLightWind, 25),
          ((l) => l.presetStrongWind, 50),
        ],
      ),
      _Field(
        symbol: 'ε',
        label: (l) => l.fieldEmissivity,
        unit: '–',
        read: (i) => i.emissivity,
        write: (i, v) => i.copyWith(emissivity: v),
        min: 0,
        minInclusive: true,
        max: 1,
        presets: [
          ((l) => l.presetPolishedAluminium, 0.05),
          ((l) => l.presetOxidisedAluminium, 0.2),
          ((l) => l.presetStainlessJacket, 0.35),
          ((l) => l.presetPvcJacket, 0.92),
          ((l) => l.presetPaintedSurface, 0.9),
        ],
      ),
    ],
  ),
];

/// Grid of all tube variables. Invalid entries show an error and leave the
/// last valid value in place.
class InputsPanel extends StatefulWidget {
  const InputsPanel({super.key, required this.inputs, required this.onChanged});

  final TubeInputs inputs;
  final ValueChanged<TubeInputs> onChanged;

  @override
  State<InputsPanel> createState() => _InputsPanelState();
}

class _InputsPanelState extends State<InputsPanel> {
  final _controllers = <_Field, TextEditingController>{};
  final _errors = <_Field, String?>{};
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    for (final (_, fields) in _sections) {
      for (final field in fields) {
        _controllers[field] = TextEditingController(
          text: fmtInput(field.read(widget.inputs)),
        );
      }
    }
  }

  /// On a language switch, rewrite valid entries with the new decimal
  /// separator and translate the error messages.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_locale != null && locale != _locale) {
      final l10n = AppLocalizations.of(context);
      for (final MapEntry(key: field, value: controller)
          in _controllers.entries) {
        if (_errors[field] == null) {
          controller.text = fmtInput(field.read(widget.inputs));
        } else {
          _errors[field] = field.validate(parseNumber(controller.text), l10n);
        }
      }
    }
    _locale = locale;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onText(_Field field, String text) {
    final value = parseNumber(text);
    final error = field.validate(value, AppLocalizations.of(context));
    setState(() => _errors[field] = error);
    if (error == null) widget.onChanged(field.write(widget.inputs, value!));
  }

  void _applyPreset(_Field field, double value) {
    _controllers[field]!.text = fmtInput(value);
    _onText(field, _controllers[field]!.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (title, fields) in _sections) ...[
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Text(
              title(l10n),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final columns = (constraints.maxWidth / 180).floor().clamp(1, 4);
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final field in fields)
                    SizedBox(width: width, child: _buildField(field)),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildField(_Field field) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _controllers[field],
      onChanged: (text) => _onText(field, text),
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormulaText(
              field.symbol,
              style: const TextStyle(fontStyle: FontStyle.italic),
              symbolTooltips: false,
            ),
            Flexible(
              child: Text(
                '  ${field.label(l10n)}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        errorText: _errors[field],
        suffixText: field.unit,
        suffixStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        suffixIcon: field.presets.isEmpty
            ? null
            : PopupMenuButton<double>(
                tooltip: l10n.presetsTooltip,
                icon: const Icon(Icons.arrow_drop_down),
                onSelected: (value) => _applyPreset(field, value),
                itemBuilder: (context) => [
                  for (final (name, value) in field.presets)
                    PopupMenuItem(
                      value: value,
                      child: Row(
                        children: [
                          Expanded(child: Text(name(l10n))),
                          const SizedBox(width: 16),
                          Text(
                            '${fmtInput(value)} ${field.unit}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Collapsible card around the variables. When collapsed, the header shows a
/// one-line summary of the main values. The [child] is kept alive while
/// collapsed so half-typed entries survive.
class InputsSection extends StatefulWidget {
  const InputsSection({super.key, required this.inputs, required this.child});

  final TubeInputs inputs;
  final Widget child;

  @override
  State<InputsSection> createState() => _InputsSectionState();
}

class _InputsSectionState extends State<InputsSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i = widget.inputs;
    return Card.outlined(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        maintainState: true,
        onExpansionChanged: (value) => setState(() => _expanded = value),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(Icons.tune, color: theme.colorScheme.primary),
        title: Text(
          AppLocalizations.of(context).variables,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: _expanded
            ? null
            : FormulaText(
                'T_f = ${fmtInput(i.fluidTemp)} °C  ·  '
                'T_∞ = ${fmtInput(i.ambientTemp)} °C  ·  '
                'L = ${fmtInput(i.length)} m  ·  '
                'D_i = ${fmtInput(i.innerDiameter)} mm  ·  '
                't_{ins} = ${fmtInput(i.insulationThickness)} mm',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [widget.child],
      ),
    );
  }
}
