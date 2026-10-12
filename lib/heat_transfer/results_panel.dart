import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'formula_text.dart';
import 'heat_labels.dart';
import 'heat_model.dart';
import 'heat_palette.dart';

/// Result of every stage and the total, as a table. Tapping a row selects it
/// for the detail pane; the `null` selection is the total.
class ResultsPanel extends StatelessWidget {
  const ResultsPanel({
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final palette = HeatPalette.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

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
        Card.outlined(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final numberWidth = constraints.maxWidth < 480 ? 74.0 : 104.0;
              return Column(
                children: [
                  _Row(
                    numberWidth: numberWidth,
                    title: Text(l10n.resultsStage, style: muted),
                    values: const ['R  [K/W]', 'ΔT  [K]', 'Q  [W]'],
                    valueStyle: muted,
                  ),
                  const Divider(height: 1),
                  for (final s in result.stages)
                    _Row(
                      numberWidth: numberWidth,
                      accent: palette.mechanism(s.stage.mechanism),
                      selected: selected == s.stage,
                      onTap: () => onSelected(s.stage),
                      leading: Icon(
                        mechanismIcon(s.stage.mechanism),
                        size: 18,
                        color: palette.mechanism(s.stage.mechanism),
                      ),
                      title: _Title(
                        s.stage.title(l10n),
                        s.stage == HeatStage.outerConvection ||
                                s.stage == HeatStage.outerRadiation
                            ? '${s.stage.mechanism.law(l10n)}  ·  '
                                  '${l10n.inParallel}'
                            : s.stage.mechanism.law(l10n),
                      ),
                      values: [
                        fmt(s.resistance),
                        fmt(s.deltaT),
                        fmt(s.heatRate),
                      ],
                    ),
                  const Divider(height: 1),
                  _Row(
                    numberWidth: numberWidth,
                    accent: theme.colorScheme.primary,
                    selected: selected == null,
                    onTap: () => onSelected(null),
                    leading: Icon(
                      Icons.functions,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    title: _Title(l10n.total, l10n.totalPath),
                    values: [
                      fmt(result.totalResistance),
                      fmt(result.fluidTemp - result.ambientTemp),
                      fmt(result.heatRate),
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
        const SizedBox(height: 8),
        FormulaText(
          "q' = ${fmt(result.heatRatePerMetre)} W/m   ·   "
          'T_s = ${fmtTemp(result.surfaceTemp)} °C   ·   '
          '${l10n.resultsTubeLength(fmtInput(result.inputs.length))}',
          style: muted,
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.title, this.subtitle);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, overflow: TextOverflow.ellipsis),
        Text(
          subtitle,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.numberWidth,
    required this.title,
    required this.values,
    this.leading,
    this.accent,
    this.selected = false,
    this.onTap,
    this.valueStyle,
  });

  final double numberWidth;
  final Widget title;
  final List<String> values;
  final Widget? leading;
  final Color? accent;
  final bool selected;
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
          child: Row(
            children: [
              SizedBox(width: 26, child: leading),
              Expanded(child: title),
              for (final value in values)
                SizedBox(
                  width: numberWidth,
                  child: FormulaText(
                    value,
                    textAlign: TextAlign.right,
                    style: (valueStyle ?? theme.textTheme.bodyMedium)?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
