import 'dart:math' as math;

/// Litres in a cubic metre.
const double litresPerCubicMetre = 1000.0;

/// Variables of the liquid expansion calculation.
class ExpansionInputs {
  const ExpansionInputs({
    this.useTubeGeometry = false,
    this.volume = 1,
    this.innerDiameter = 50,
    this.length = 100,
    this.densityCold = 999.7,
    this.densityHot = 965.3,
  });

  /// Whether the initial volume V₀ is calculated from [innerDiameter] and
  /// [length] instead of taken directly from [volume].
  final bool useTubeGeometry;

  /// Direct initial (cold) system volume V₀ in m³.
  final double volume;

  /// Inner diameter D_i of the pipe in mm, used when [useTubeGeometry] is true.
  final double innerDiameter;

  /// Length L of the pipe in m, used when [useTubeGeometry] is true.
  final double length;

  /// Liquid density ρ₁ in the cold (initial) state, in kg/m³.
  final double densityCold;

  /// Liquid density ρ₂ in the heated state, in kg/m³.
  final double densityHot;

  /// Inner radius r₁ of the pipe in m.
  double get innerRadius => innerDiameter / 2000;

  ExpansionInputs copyWith({
    bool? useTubeGeometry,
    double? volume,
    double? innerDiameter,
    double? length,
    double? densityCold,
    double? densityHot,
  }) {
    return ExpansionInputs(
      useTubeGeometry: useTubeGeometry ?? this.useTubeGeometry,
      volume: volume ?? this.volume,
      innerDiameter: innerDiameter ?? this.innerDiameter,
      length: length ?? this.length,
      densityCold: densityCold ?? this.densityCold,
      densityHot: densityHot ?? this.densityHot,
    );
  }
}

/// Result of the liquid expansion calculation.
class ExpansionResult {
  const ExpansionResult({required this.inputs});

  final ExpansionInputs inputs;

  /// Whether the heated density is lower than the cold density so the liquid
  /// expands.
  bool get densityValid => inputs.densityHot < inputs.densityCold;

  /// Initial (cold) liquid volume V₀ in m³.
  double get initialVolume => inputs.useTubeGeometry
      ? cylinderVolume(inputs.innerRadius, inputs.length)
      : inputs.volume;

  /// Initial (cold) liquid volume V₀ in L.
  double get initialLitres => initialVolume * litresPerCubicMetre;

  /// Mass of the liquid in the network, m = ρ₁·V₀, in kg.
  double get mass => inputs.densityCold * initialVolume;

  /// Heated liquid volume V₂ = m / ρ₂ = V₀·(ρ₁ / ρ₂), in m³.
  double get finalVolume => mass / inputs.densityHot;

  /// Heated liquid volume V₂ in L.
  double get finalLitres => finalVolume * litresPerCubicMetre;

  /// Volume expansion ΔV = V₂ − V₀, in m³.
  double get expansionVolume => finalVolume - initialVolume;

  /// Volume expansion ΔV in L.
  double get expansionLitres => expansionVolume * litresPerCubicMetre;
}

/// Volume of a cylinder of [radius] (in m) and [length] (in m), in m³:
/// V = π·r²·L.
double cylinderVolume(double radius, double length) =>
    math.pi * radius * radius * length;

ExpansionResult calculateExpansion(ExpansionInputs inputs) =>
    ExpansionResult(inputs: inputs);
