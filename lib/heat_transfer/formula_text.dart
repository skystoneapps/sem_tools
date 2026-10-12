import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart';

import '../l10n/app_localizations.dart';
import 'symbol_glossary.dart';

const _superscripts = {
  '0': '⁰',
  '1': '¹',
  '2': '²',
  '3': '³',
  '4': '⁴',
  '5': '⁵',
  '6': '⁶',
  '7': '⁷',
  '8': '⁸',
  '9': '⁹',
  '-': '⁻',
};

String get _decimalSeparator =>
    numberFormatSymbols[Intl.shortLocale(Intl.getCurrentLocale())]
        ?.DECIMAL_SEP ??
    '.';

/// Puts a number formatted with `.` and `-` into the notation of the current
/// [Intl.defaultLocale]: a decimal comma for Dutch, and a proper minus sign.
String _localise(String number) =>
    number.replaceFirst('.', _decimalSeparator).replaceFirst('-', '−');

/// The same for TeX, where a decimal comma must be braced (`{,}`) so it is not
/// typeset as punctuation followed by a space.
String _texLocalise(String number) =>
    number.replaceFirst('.', _decimalSeparator == ',' ? '{,}' : '.');

/// [value] with [significant] digits as a mantissa (with `.` and `-`) and,
/// for very small or very large magnitudes, a power of ten.
(String, int?) _numberParts(double value, int significant) {
  final magnitude = value.abs();
  if (magnitude >= 1e-3 && magnitude < 1e6) {
    final exponent = (math.log(magnitude) / math.ln10).floor();
    final decimals = (significant - 1 - exponent).clamp(0, 10);
    return (value.toStringAsFixed(decimals), null);
  }
  final parts = value.toStringAsExponential(significant - 1).split('e');
  return (parts[0], int.parse(parts[1]));
}

String _trimmedInput(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(6).replaceFirst(RegExp(r'0+$'), '');

/// Formats [value] with [significant] digits, switching to ×10ⁿ notation for
/// very small or very large magnitudes.
String fmt(double value, [int significant = 4]) {
  if (value.isNaN) return '—';
  if (value.isInfinite) return value > 0 ? '∞' : '−∞';
  if (value == 0) return '0';
  final (mantissa, exponent) = _numberParts(value, significant);
  if (exponent == null) return _localise(mantissa);
  final superscript = '$exponent'.split('').map((c) => _superscripts[c] ?? c);
  return '${_localise(mantissa)}×10${superscript.join()}';
}

/// Number of decimals for every displayed temperature.
const temperatureDecimals = 2;

/// Formats a temperature (°C or K) with [temperatureDecimals] decimals.
String fmtTemp(double temperature) =>
    _localise(temperature.toStringAsFixed(temperatureDecimals));

/// Number of decimals for calculated heat flows, areas and coefficients.
/// Resistances and temperature differences keep [fmt]'s significant digits,
/// as they are often far below 0.01.
const valueDecimals = 2;

/// Formats a calculated heat flow, area or coefficient with [valueDecimals]
/// decimals.
String fmtValue(double value) =>
    _localise(value.toStringAsFixed(valueDecimals));

/// Formats a user-entered value without trailing zeros.
String fmtInput(double value) => _localise(_trimmedInput(value));

/// TeX version of [fmt].
String texNum(double value, [int significant = 4]) {
  if (value.isNaN) return r'	ext{—}';
  if (value.isInfinite) return value > 0 ? r'\infty' : r'-\infty';
  if (value == 0) return '0';
  final (mantissa, exponent) = _numberParts(value, significant);
  final m = _texLocalise(mantissa);
  return exponent == null ? m : '$m \\times 10^{$exponent}';
}

/// Formats a value with [decimals] decimals, for TeX.
String texFixed(double value, int decimals) =>
    _texLocalise(value.toStringAsFixed(decimals));

/// TeX version of [fmtValue].
String texValue(double value) => texFixed(value, valueDecimals);

/// TeX version of [fmtTemp].
String texTemp(double temperature) =>
    texFixed(temperature, temperatureDecimals);

/// TeX version of [fmtInput].
String texInput(double value) => _texLocalise(_trimmedInput(value));

/// Parses a number typed with either a decimal point or comma.
double? parseNumber(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.').replaceAll('−', '-'));

/// Renders a formula written in a tiny markup: `_x` / `_{xy}` for subscripts
/// and `^x` / `^{xy}` for superscripts.
///
/// Known symbols (see [describeSymbol]) get a dotted underline and a tooltip
/// explaining them, unless [symbolTooltips] is false.
class FormulaText extends StatelessWidget {
  const FormulaText(
    this.source, {
    super.key,
    this.style,
    this.textAlign,
    this.symbolTooltips = true,
  });

  final String source;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool symbolTooltips;

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style.merge(style);
    final spans = <InlineSpan>[];
    var last = 0;
    if (symbolTooltips) {
      final l10n = AppLocalizations.of(context);
      for (final match in symbolPattern.allMatches(source)) {
        final symbol = match[0]!;
        final info = describeSymbol(symbol, l10n);
        if (info == null) continue;
        spans
          ..addAll(_parse(source.substring(last, match.start), base))
          ..add(_symbolSpan(symbol, info, base));
        last = match.end;
      }
    }
    spans.addAll(_parse(source.substring(last), base));
    return Text.rich(
      TextSpan(children: spans),
      style: base,
      textAlign: textAlign,
    );
  }

  static InlineSpan _symbolSpan(
    String symbol,
    (String, String?) info,
    TextStyle base,
  ) {
    final (description, unit) = info;
    final underlined = base.copyWith(
      decoration: TextDecoration.underline,
      decorationStyle: TextDecorationStyle.dotted,
      decorationColor: base.color?.withValues(alpha: 0.5),
    );
    return WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Tooltip(
        message: unit == null ? description : '$description  [$unit]',
        waitDuration: const Duration(milliseconds: 250),
        child: MouseRegion(
          cursor: SystemMouseCursors.help,
          child: Text.rich(
            TextSpan(style: underlined, children: _parse(symbol, base)),
            style: base,
          ),
        ),
      ),
    );
  }

  static List<InlineSpan> _parse(String source, TextStyle base) {
    final spans = <InlineSpan>[];
    final buffer = StringBuffer();
    final fontSize = base.fontSize ?? 14;
    final small = base.copyWith(fontSize: fontSize * 0.7);

    void flush() {
      if (buffer.isEmpty) return;
      spans.add(TextSpan(text: buffer.toString()));
      buffer.clear();
    }

    var i = 0;
    while (i < source.length) {
      final c = source[i];
      if ((c == '_' || c == '^') && i + 1 < source.length) {
        flush();
        String group;
        if (source[i + 1] == '{') {
          final end = source.indexOf('}', i + 2);
          group = source.substring(i + 2, end);
          i = end + 1;
        } else {
          group = source[i + 1];
          i += 2;
        }
        final isSub = c == '_';
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Transform.translate(
              offset: Offset(0, isSub ? fontSize * 0.22 : -fontSize * 0.42),
              child: Text(group, style: small),
            ),
          ),
        );
      } else {
        buffer.write(c);
        i++;
      }
    }
    flush();
    return spans;
  }
}
