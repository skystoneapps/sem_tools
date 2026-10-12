import 'package:flutter/material.dart';

import '../domain/heat_model.dart';

/// Colours used by the tube drawing and the detail pane, per brightness.
class HeatPalette {
  const HeatPalette._({
    required this.convection,
    required this.conduction,
    required this.radiation,
    required this.insulationDark,
    required this.insulationLight,
    required this.insulationFace,
    required this.onInsulation,
    required this.metalDark,
    required this.metalMid,
    required this.metalLight,
    required this.outline,
    required this.text,
    required this.mutedText,
  });

  factory HeatPalette.of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = scheme.brightness == Brightness.dark;
    return HeatPalette._(
      convection: dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      conduction: dark ? const Color(0xFFFB923C) : const Color(0xFFC2410C),
      radiation: dark ? const Color(0xFFF472B6) : const Color(0xFFBE185D),
      insulationDark: dark ? const Color(0xFF4F4430) : const Color(0xFFBFA46A),
      insulationLight: dark ? const Color(0xFF8F7E58) : const Color(0xFFF5E9CA),
      insulationFace: dark ? const Color(0xFF746645) : const Color(0xFFEBDAB0),
      onInsulation: dark ? const Color(0xFFF5EEDC) : const Color(0xFF3B3221),
      metalDark: dark ? const Color(0xFF4A535C) : const Color(0xFF6B7580),
      metalMid: dark ? const Color(0xFF7C8690) : const Color(0xFFA7B0B9),
      metalLight: dark ? const Color(0xFFB8C0C8) : const Color(0xFFE6EAEE),
      outline: scheme.onSurface.withValues(alpha: dark ? 0.45 : 0.4),
      text: scheme.onSurface,
      mutedText: scheme.onSurfaceVariant,
    );
  }

  final Color convection;
  final Color conduction;
  final Color radiation;
  final Color insulationDark;
  final Color insulationLight;
  final Color insulationFace;
  final Color onInsulation;
  final Color metalDark;
  final Color metalMid;
  final Color metalLight;
  final Color outline;
  final Color text;
  final Color mutedText;

  Color mechanism(Mechanism m) => switch (m) {
    Mechanism.convection => convection,
    Mechanism.conduction => conduction,
    Mechanism.radiation => radiation,
  };
}

IconData mechanismIcon(Mechanism m) => switch (m) {
  Mechanism.convection => Icons.air,
  Mechanism.conduction => Icons.layers_outlined,
  Mechanism.radiation => Icons.wb_sunny_outlined,
};

const _temperatureStops = <(double, Color)>[
  (-20, Color(0xFF1D4ED8)),
  (15, Color(0xFF7DD3FC)),
  (40, Color(0xFFFDE68A)),
  (90, Color(0xFFFB923C)),
  (200, Color(0xFFDC2626)),
  (400, Color(0xFF7F1D1D)),
];

/// Maps a temperature in °C to a cold-blue → hot-red colour.
Color temperatureColor(double celsius) {
  if (celsius <= _temperatureStops.first.$1) return _temperatureStops.first.$2;
  for (var i = 1; i < _temperatureStops.length; i++) {
    final (t1, c1) = _temperatureStops[i];
    if (celsius <= t1) {
      final (t0, c0) = _temperatureStops[i - 1];
      return Color.lerp(c0, c1, (celsius - t0) / (t1 - t0))!;
    }
  }
  return _temperatureStops.last.$2;
}
