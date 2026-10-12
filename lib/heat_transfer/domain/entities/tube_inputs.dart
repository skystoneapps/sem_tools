/// All user-adjustable variables. Lengths of the cross-section are in mm,
/// everything else in SI units (temperatures in °C).
class TubeInputs {
  const TubeInputs({
    this.inletTemp = 150,
    this.ambientTemp = 20,
    this.massFlow = 0.1,
    this.specificHeat = 4186,
    this.length = 10,
    this.innerDiameter = 50,
    this.wallThickness = 4,
    this.insulationThickness = 30,
    this.kPipe = 45,
    this.kInsulation = 0.04,
    this.hInner = 1000,
    this.hOuter = 10,
    this.emissivity = 0.9,
    this.includeRadiation = true,
    this.constantFluidTemp = false,
  });

  /// Fluid temperature where it enters the tube.
  final double inletTemp;
  final double ambientTemp;

  /// Mass flow rate of the fluid in kg/s.
  final double massFlow;

  /// Specific heat capacity of the fluid in J/(kg·K).
  final double specificHeat;
  final double length;
  final double innerDiameter;
  final double wallThickness;
  final double insulationThickness;
  final double kPipe;
  final double kInsulation;
  final double hInner;
  final double hOuter;
  final double emissivity;

  /// When false, the surface is treated as if it does not radiate (ε = 0).
  final bool includeRadiation;

  /// Simplification: the fluid keeps its inlet temperature along the whole
  /// tube when calculating the heat loss.
  final bool constantFluidTemp;

  /// Emissivity used in the calculation.
  double get effectiveEmissivity => includeRadiation ? emissivity : 0;

  /// Inner radius of the pipe in m.
  double get r1 => innerDiameter / 2000;

  /// Outer radius of the pipe (= inner radius of the insulation) in m.
  double get r2 => r1 + wallThickness / 1000;

  /// Outer radius of the insulation in m.
  double get r3 => r2 + insulationThickness / 1000;

  /// Heat capacity rate ṁ·c_p of the fluid in W/K.
  double get capacityRate => massFlow * specificHeat;

  TubeInputs copyWith({
    double? inletTemp,
    double? ambientTemp,
    double? massFlow,
    double? specificHeat,
    double? length,
    double? innerDiameter,
    double? wallThickness,
    double? insulationThickness,
    double? kPipe,
    double? kInsulation,
    double? hInner,
    double? hOuter,
    double? emissivity,
    bool? includeRadiation,
    bool? constantFluidTemp,
  }) {
    return TubeInputs(
      inletTemp: inletTemp ?? this.inletTemp,
      ambientTemp: ambientTemp ?? this.ambientTemp,
      massFlow: massFlow ?? this.massFlow,
      specificHeat: specificHeat ?? this.specificHeat,
      length: length ?? this.length,
      innerDiameter: innerDiameter ?? this.innerDiameter,
      wallThickness: wallThickness ?? this.wallThickness,
      insulationThickness: insulationThickness ?? this.insulationThickness,
      kPipe: kPipe ?? this.kPipe,
      kInsulation: kInsulation ?? this.kInsulation,
      hInner: hInner ?? this.hInner,
      hOuter: hOuter ?? this.hOuter,
      emissivity: emissivity ?? this.emissivity,
      includeRadiation: includeRadiation ?? this.includeRadiation,
      constantFluidTemp: constantFluidTemp ?? this.constantFluidTemp,
    );
  }
}
