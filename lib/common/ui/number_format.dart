/// Locale-aware number formatting for the UI and for TeX formulas. Numbers
/// follow [Intl.defaultLocale], which the app sets to the active language.
library;

import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart';

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

/// Number of decimals for calculated values such as heat flows, areas,
/// coefficients and amounts of money. Resistances and temperature differences
/// keep [fmt]'s significant digits, as they are often far below 0.01.
const valueDecimals = 2;

/// Formats a calculated value with [valueDecimals] decimals.
String fmtValue(double value) =>
    _localise(value.toStringAsFixed(valueDecimals));

/// Formats a user-entered value without trailing zeros.
String fmtInput(double value) => _localise(_trimmedInput(value));

/// TeX version of [fmt].
String texNum(double value, [int significant = 4]) {
  if (value.isNaN) return r'\text{—}';
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

/// Formats an amount of money in the current locale, e.g. "€128.69" or
/// "€ 128,69".
String fmtCurrency(double value, {int decimals = 2, String symbol = '€'}) =>
    NumberFormat.currency(
      locale: Intl.getCurrentLocale(),
      symbol: symbol,
      decimalDigits: decimals,
    ).format(value);
