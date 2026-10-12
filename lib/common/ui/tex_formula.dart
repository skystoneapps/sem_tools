import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../l10n/app_localizations.dart';

/// TeX units, typeset upright after a thin space.
const texWatt = r'\,\mathrm{W}';
const texKelvin = r'\,\mathrm{K}';
const texCelsius = r'\,{}^{\circ}\mathrm{C}';
const texResistance = r'\,\mathrm{K/W}';
const texSquareMetre = r'\,\mathrm{m^2}';
const texMetre = r'\,\mathrm{m}';
const texWattPerMetre = r'\,\mathrm{W/m}';
const texHeatTransferCoefficient = r'\,\mathrm{W/(m^2\,K)}';

/// Typesets a TeX formula. Long formulas wrap onto the next line after an
/// `=` sign instead of overflowing.
class TexFormula extends StatelessWidget {
  const TexFormula(this.tex, {super.key, this.style});

  final String tex;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textStyle = DefaultTextStyle.of(context).style.merge(style);
    final fontSize = textStyle.fontSize ?? 14;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      // TeX drops the space after a relation that ends a piece; put back
      // its "thick space" of 5/18 em.
      spacing: fontSize * 5 / 18,
      runSpacing: 8,
      children: [
        for (final part in splitAtRelations(tex))
          // A single side wider than the pane is scaled down rather than
          // overflowing.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Math.tex(
              part,
              textStyle: textStyle,
              onErrorFallback: (error) => Text(part, style: textStyle),
            ),
          ),
      ],
    );
  }
}

/// Splits [tex] after every `=` that is not nested in braces or
/// `\left … \right`, so each piece is a self-contained formula.
///
/// Breaking at operators as well (as `Math.texBreak` does) would lose their
/// spacing, and lines rarely need to break inside a single side anyway.
List<String> splitAtRelations(String tex) {
  final parts = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < tex.length; i++) {
    if (tex.startsWith(r'\left', i)) {
      depth++;
    } else if (tex.startsWith(r'\right', i)) {
      depth--;
    } else if (tex[i] == '{') {
      depth++;
    } else if (tex[i] == '}') {
      depth--;
    } else if (tex[i] == '=' && depth == 0) {
      parts.add(tex.substring(start, i + 1));
      start = i + 1;
    }
  }
  if (start < tex.length) parts.add(tex.substring(start));
  return parts;
}

/// A worked step of a [Derivation]: an explanation and a TeX formula.
typedef DerivationStep = (String label, String tex);

/// An entry of a [SymbolLegend]: a symbol in TeX, what it means and its unit
/// (`null` when it has none or more than one).
typedef LegendEntry = (String tex, String description, String? unit);

/// A worked calculation: the governing equation in a [color]ed box headed by
/// the name of the [law], the numbered [steps], and a "where:" list of the
/// symbols used.
class Derivation extends StatelessWidget {
  const Derivation({
    super.key,
    required this.color,
    required this.law,
    required this.formula,
    required this.steps,
    required this.legend,
  });

  final Color color;
  final String law;

  /// The governing equation, in TeX.
  final String formula;
  final List<DerivationStep> steps;
  final List<LegendEntry> legend;

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
        SymbolLegend(entries: legend),
      ],
    );
  }
}

/// Textbook-style "where:" list explaining the symbols of a derivation.
class SymbolLegend extends StatelessWidget {
  const SymbolLegend({super.key, required this.entries});

  final List<LegendEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final style = theme.textTheme.bodySmall?.copyWith(color: muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.where, style: style?.copyWith(fontStyle: FontStyle.italic)),
        const SizedBox(height: 6),
        for (final (tex, description, unit) in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                // Symbols keep their natural width; the minimum lines up
                // the descriptions for all but the widest symbols.
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 64),
                  child: Math.tex(
                    tex,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: description,
                      children: [
                        if (unit != null)
                          TextSpan(
                            text: '  [$unit]',
                            style: TextStyle(
                              color: muted.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                    style: style,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
