import 'dart:math' as math;

/// Stefan–Boltzmann constant in W/(m²·K⁴).
const double stefanBoltzmann = 5.670374419e-8;

/// Offset between degrees Celsius and kelvin.
const double kelvinOffset = 273.15;

/// The three heat transport mechanisms. Display names live in
/// `heat_labels.dart`.
enum Mechanism { convection, conduction, radiation }

/// One step on the path of heat from the fluid to the surroundings.
enum HeatStage {
  innerConvection(Mechanism.convection),
  pipeConduction(Mechanism.conduction),
  insulationConduction(Mechanism.conduction),
  outerConvection(Mechanism.convection),
  outerRadiation(Mechanism.radiation);

  const HeatStage(this.mechanism);

  final Mechanism mechanism;
}

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
    );
  }
}

/// Result of a single stage. [tIn] and [tOut] are the temperatures (°C) on
/// either side of the stage; [heatRate] is the heat flowing through it (W).
class StageResult {
  const StageResult({
    required this.stage,
    required this.resistance,
    required this.tIn,
    required this.tOut,
    required this.heatRate,
    this.area,
    this.coefficient,
  });

  final HeatStage stage;

  /// Thermal resistance in K/W.
  final double resistance;
  final double tIn;
  final double tOut;
  final double heatRate;

  /// Heat transfer area in m² (convection and radiation only).
  final double? area;

  /// h for convection, linearised h_rad for radiation, in W/(m²·K).
  final double? coefficient;

  double get deltaT => tIn - tOut;
}

class HeatTransferResult {
  const HeatTransferResult({
    required this.inputs,
    required this.stages,
    required this.heatRate,
    required this.surfaceTemp,
    required this.outletTemp,
    required this.meanFluidTemp,
  });

  final TubeInputs inputs;

  /// Results of every stage, in the order heat passes through them. They are
  /// evaluated at the [meanFluidTemp].
  final List<StageResult> stages;

  /// Total heat transported from the fluid to the surroundings (W).
  final double heatRate;

  /// Outer surface temperature T_s in °C, at the mean fluid temperature.
  final double surfaceTemp;

  /// Fluid temperature where it leaves the tube.
  final double outletTemp;

  /// Logarithmic mean fluid temperature T_m between inlet and outlet.
  final double meanFluidTemp;

  double get inletTemp => inputs.inletTemp;
  double get ambientTemp => inputs.ambientTemp;

  StageResult operator [](HeatStage stage) =>
      stages.firstWhere((s) => s.stage == stage);

  double get heatRatePerMetre => heatRate / inputs.length;

  /// Combined resistance of the parallel outer convection and radiation.
  double get outerResistance => _outerResistance(stages);

  double get totalResistance => _totalResistance(stages);
}

double _area(double r, double length) => 2 * math.pi * r * length;

double _toKelvin(double celsius) => celsius + kelvinOffset;

/// Linearised radiation coefficient h_rad = εσ(T_s² + T∞²)(T_s + T∞).
double radiationCoefficient(double emissivity, double tsC, double tInfC) {
  final ts = _toKelvin(tsC);
  final tInf = _toKelvin(tInfC);
  return emissivity * stefanBoltzmann * (ts * ts + tInf * tInf) * (ts + tInf);
}

/// Logarithmic mean of the fluid temperature between [tIn] and [tOut],
/// measured from the ambient temperature [tInf].
double logMeanTemperature(double tIn, double tOut, double tInf) {
  final dIn = tIn - tInf;
  final dOut = tOut - tInf;
  if (dIn.abs() < 1e-12 || dOut.abs() < 1e-12) return tInf;
  if ((dIn - dOut).abs() < 1e-9 * dIn.abs()) return tInf + (dIn + dOut) / 2;
  return tInf + (dIn - dOut) / math.log(dIn / dOut);
}

/// Solves steady-state heat transport through the insulated tube.
///
/// Across the wall, the stages form a series chain of thermal resistances,
/// except at the outer surface, where convection and radiation act in
/// parallel. Radiation is non-linear, so the surface temperature is found by
/// bisection. Along the tube, the fluid temperature approaches ambient
/// exponentially; the stages are evaluated at the logarithmic mean fluid
/// temperature, which is iterated together with the outlet temperature.
HeatTransferResult calculateHeatTransfer(TubeInputs inputs) {
  final tIn = inputs.inletTemp;
  final tInf = inputs.ambientTemp;

  var meanTemp = tIn;
  var cross = _solveCrossSection(inputs, meanTemp);
  var outletTemp = tIn;
  for (var i = 0; i < 100; i++) {
    final conductance = 1 / _totalResistance(cross.stages);
    outletTemp =
        tInf + (tIn - tInf) * math.exp(-conductance / inputs.capacityRate);
    final next = logMeanTemperature(tIn, outletTemp, tInf);
    if ((next - meanTemp).abs() < 1e-10) break;
    meanTemp = next;
    cross = _solveCrossSection(inputs, meanTemp);
  }

  return HeatTransferResult(
    inputs: inputs,
    stages: cross.stages,
    heatRate: cross.heatRate,
    surfaceTemp: cross.surfaceTemp,
    outletTemp: outletTemp,
    meanFluidTemp: meanTemp,
  );
}

double _outerResistance(List<StageResult> stages) {
  final conductance =
      1 / stages[HeatStage.outerConvection.index].resistance +
      1 / stages[HeatStage.outerRadiation.index].resistance;
  return conductance == 0 ? double.infinity : 1 / conductance;
}

double _totalResistance(List<StageResult> stages) =>
    stages[HeatStage.innerConvection.index].resistance +
    stages[HeatStage.pipeConduction.index].resistance +
    stages[HeatStage.insulationConduction.index].resistance +
    _outerResistance(stages);

/// Heat transport across the tube wall at fluid temperature [tf].
({List<StageResult> stages, double heatRate, double surfaceTemp})
_solveCrossSection(TubeInputs inputs, double tf) {
  final length = inputs.length;
  final innerArea = _area(inputs.r1, length);
  final outerArea = _area(inputs.r3, length);

  final rInnerConv = 1 / (inputs.hInner * innerArea);
  final rPipe =
      math.log(inputs.r2 / inputs.r1) / (2 * math.pi * inputs.kPipe * length);
  final rInsulation =
      math.log(inputs.r3 / inputs.r2) /
      (2 * math.pi * inputs.kInsulation * length);

  // Resistance between the fluid and the outer surface.
  final rInside = rInnerConv + rPipe + rInsulation;
  final tInf = inputs.ambientTemp;

  double convectionOut(double ts) => inputs.hOuter * outerArea * (ts - tInf);
  double radiationOut(double ts) =>
      inputs.effectiveEmissivity *
      stefanBoltzmann *
      outerArea *
      (math.pow(_toKelvin(ts), 4) - math.pow(_toKelvin(tInf), 4));

  // f(ts) = heat arriving − heat leaving; monotonically decreasing in ts.
  double f(double t) => (tf - t) / rInside - convectionOut(t) - radiationOut(t);
  var lo = math.min(tf, tInf);
  var hi = math.max(tf, tInf);
  final fLo = f(lo);
  for (var i = 0; i < 200 && hi - lo > 1e-12; i++) {
    final mid = (lo + hi) / 2;
    if ((f(mid) > 0) == (fLo > 0)) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  final ts = (lo + hi) / 2;

  final q = convectionOut(ts) + radiationOut(ts);
  final t1 = tf - q * rInnerConv;
  final t2 = t1 - q * rPipe;
  final hRad = radiationCoefficient(inputs.effectiveEmissivity, ts, tInf);

  // Listed in HeatStage order, so `stages[stage.index]` is that stage.
  return (
    heatRate: q,
    surfaceTemp: ts,
    stages: [
      StageResult(
        stage: HeatStage.innerConvection,
        resistance: rInnerConv,
        tIn: tf,
        tOut: t1,
        heatRate: q,
        area: innerArea,
        coefficient: inputs.hInner,
      ),
      StageResult(
        stage: HeatStage.pipeConduction,
        resistance: rPipe,
        tIn: t1,
        tOut: t2,
        heatRate: q,
      ),
      StageResult(
        stage: HeatStage.insulationConduction,
        resistance: rInsulation,
        tIn: t2,
        tOut: ts,
        heatRate: q,
      ),
      StageResult(
        stage: HeatStage.outerConvection,
        resistance: 1 / (inputs.hOuter * outerArea),
        tIn: ts,
        tOut: tInf,
        heatRate: convectionOut(ts),
        area: outerArea,
        coefficient: inputs.hOuter,
      ),
      StageResult(
        stage: HeatStage.outerRadiation,
        resistance: 1 / (hRad * outerArea),
        tIn: ts,
        tOut: tInf,
        heatRate: radiationOut(ts),
        area: outerArea,
        coefficient: hRad,
      ),
    ],
  );
}
