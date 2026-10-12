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
    this.fluidTemp = 150,
    this.ambientTemp = 20,
    this.length = 10,
    this.innerDiameter = 50,
    this.wallThickness = 4,
    this.insulationThickness = 30,
    this.kPipe = 45,
    this.kInsulation = 0.04,
    this.hInner = 1000,
    this.hOuter = 10,
    this.emissivity = 0.9,
  });

  final double fluidTemp;
  final double ambientTemp;
  final double length;
  final double innerDiameter;
  final double wallThickness;
  final double insulationThickness;
  final double kPipe;
  final double kInsulation;
  final double hInner;
  final double hOuter;
  final double emissivity;

  /// Inner radius of the pipe in m.
  double get r1 => innerDiameter / 2000;

  /// Outer radius of the pipe (= inner radius of the insulation) in m.
  double get r2 => r1 + wallThickness / 1000;

  /// Outer radius of the insulation in m.
  double get r3 => r2 + insulationThickness / 1000;

  TubeInputs copyWith({
    double? fluidTemp,
    double? ambientTemp,
    double? length,
    double? innerDiameter,
    double? wallThickness,
    double? insulationThickness,
    double? kPipe,
    double? kInsulation,
    double? hInner,
    double? hOuter,
    double? emissivity,
  }) {
    return TubeInputs(
      fluidTemp: fluidTemp ?? this.fluidTemp,
      ambientTemp: ambientTemp ?? this.ambientTemp,
      length: length ?? this.length,
      innerDiameter: innerDiameter ?? this.innerDiameter,
      wallThickness: wallThickness ?? this.wallThickness,
      insulationThickness: insulationThickness ?? this.insulationThickness,
      kPipe: kPipe ?? this.kPipe,
      kInsulation: kInsulation ?? this.kInsulation,
      hInner: hInner ?? this.hInner,
      hOuter: hOuter ?? this.hOuter,
      emissivity: emissivity ?? this.emissivity,
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
  });

  final TubeInputs inputs;

  /// Results of every stage, in the order heat passes through them.
  final List<StageResult> stages;

  /// Total heat transported from the fluid to the surroundings (W).
  final double heatRate;

  /// Outer surface temperature T_s in °C.
  final double surfaceTemp;

  double get fluidTemp => inputs.fluidTemp;
  double get ambientTemp => inputs.ambientTemp;

  StageResult operator [](HeatStage stage) =>
      stages.firstWhere((s) => s.stage == stage);

  double get heatRatePerMetre => heatRate / inputs.length;

  /// Combined resistance of the parallel outer convection and radiation.
  double get outerResistance {
    final conductance =
        1 / this[HeatStage.outerConvection].resistance +
        1 / this[HeatStage.outerRadiation].resistance;
    return conductance == 0 ? double.infinity : 1 / conductance;
  }

  double get totalResistance =>
      this[HeatStage.innerConvection].resistance +
      this[HeatStage.pipeConduction].resistance +
      this[HeatStage.insulationConduction].resistance +
      outerResistance;
}

double _area(double r, double length) => 2 * math.pi * r * length;

double _toKelvin(double celsius) => celsius + kelvinOffset;

/// Linearised radiation coefficient h_rad = εσ(T_s² + T∞²)(T_s + T∞).
double radiationCoefficient(double emissivity, double tsC, double tInfC) {
  final ts = _toKelvin(tsC);
  final tInf = _toKelvin(tInfC);
  return emissivity * stefanBoltzmann * (ts * ts + tInf * tInf) * (ts + tInf);
}

/// Solves steady-state radial heat transport through the insulated tube.
///
/// The stages form a series chain of thermal resistances, except at the outer
/// surface, where convection and radiation act in parallel. Radiation is
/// non-linear in temperature, so the surface temperature is found by
/// bisection: the heat conducted to the surface must equal the heat leaving it.
HeatTransferResult calculateHeatTransfer(TubeInputs inputs) {
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

  final tf = inputs.fluidTemp;
  final tInf = inputs.ambientTemp;

  double convectionOut(double ts) => inputs.hOuter * outerArea * (ts - tInf);
  double radiationOut(double ts) =>
      inputs.emissivity *
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
  final hRad = radiationCoefficient(inputs.emissivity, ts, tInf);

  return HeatTransferResult(
    inputs: inputs,
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
