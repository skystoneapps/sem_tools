import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'number_format.dart';

/// Text field for a number with a symbol, label, unit, range check and
/// optional presets. Invalid entries show an error and are not reported.
///
/// When [value] changes from outside (e.g. a reset or an import), or the
/// language changes, the text is rewritten — unless the user is in the middle
/// of an invalid entry.
class NumberField extends StatefulWidget {
  const NumberField({
    super.key,
    required this.symbol,
    required this.label,
    required this.unit,
    required this.value,
    required this.onChanged,
    this.min,
    this.minInclusive = false,
    this.max,
    this.presets = const [],
  });

  /// Short symbol shown in italics before the label, e.g. `P`.
  final String symbol;
  final String label;
  final String unit;
  final double value;
  final ValueChanged<double> onChanged;
  final double? min;
  final bool minInclusive;
  final double? max;

  /// Named values offered in a menu at the end of the field.
  final List<(String, double)> presets;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final _controller = TextEditingController(text: fmtInput(widget.value));
  String? _error;
  Locale? _locale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    if (_locale != null && locale != _locale) {
      if (_error == null) {
        _controller.text = fmtInput(widget.value);
      } else {
        _error = _validate(parseNumber(_controller.text));
      }
    }
    _locale = locale;
  }

  @override
  void didUpdateWidget(NumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final typed = parseNumber(_controller.text);
    if (widget.value != oldWidget.value && typed != widget.value) {
      _controller.text = fmtInput(widget.value);
      _error = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(double? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || !value.isFinite) return l10n.errorEnterNumber;
    final min = widget.min;
    if (min != null) {
      if (widget.minInclusive ? value < min : value <= min) {
        return widget.minInclusive
            ? l10n.errorAtLeast(fmtInput(min))
            : l10n.errorGreaterThan(fmtInput(min));
      }
    }
    final max = widget.max;
    if (max != null && value > max) return l10n.errorAtMost(fmtInput(max));
    return null;
  }

  void _onText(String text) {
    final value = parseNumber(text);
    final error = _validate(value);
    setState(() => _error = error);
    if (error == null) widget.onChanged(value!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return TextField(
      controller: _controller,
      onChanged: _onText,
      keyboardType: const TextInputType.numberWithOptions(
        signed: true,
        decimal: true,
      ),
      style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        label: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: widget.symbol,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              TextSpan(text: '  ${widget.label}'),
            ],
          ),
          overflow: TextOverflow.ellipsis,
        ),
        errorText: _error,
        suffixText: widget.unit,
        suffixStyle: theme.textTheme.bodySmall?.copyWith(color: muted),
        suffixIcon: widget.presets.isEmpty
            ? null
            : PopupMenuButton<double>(
                tooltip: AppLocalizations.of(context).presetsTooltip,
                icon: const Icon(Icons.arrow_drop_down),
                onSelected: (value) {
                  _controller.text = fmtInput(value);
                  _onText(_controller.text);
                },
                itemBuilder: (context) => [
                  for (final (name, value) in widget.presets)
                    PopupMenuItem(
                      value: value,
                      child: Row(
                        children: [
                          Expanded(child: Text(name)),
                          const SizedBox(width: 16),
                          Text(
                            '${fmtInput(value)} ${widget.unit}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
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
