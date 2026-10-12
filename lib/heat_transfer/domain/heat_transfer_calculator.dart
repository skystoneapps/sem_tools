import 'dart:math' as math;

import 'entities/heat_stage.dart';
import 'entities/heat_transfer_result.dart';
import 'entities/tube_inputs.dart';
import 'physics.dart';

/// Solves steady-state heat transport through the insulated tube.
///
/// Across the wall, the stages form a series chain of thermal resistances,
/// except at the outer surface, where convection and radiation act in
/// parallel. Radiation is non-linear, so the surface temperature is found by
/// bisection. Along the tube, the fluid temperature approaches ambient
/// exponentially; the stages are evaluated at the logarithmic mean fluid
/// temperature, which is iterated together with the outlet temperature.
///
/// With [TubeInputs.constantFluidTemp], the fluid temperature is instead
/// taken as constant: the heat loss follows from the inlet temperature and
/// the outlet temperature from a plain energy balance on the fluid.
HeatTransferResult calculateHeatTransfer(TubeInputs inputs) {
  final exact = _calculateExact(inputs);
  if (!inputs.constantFluidTemp) return exact;

  final cross = _solveCrossSection(inputs, inputs.inletTemp);
  return HeatTransferResult(
    inputs: inputs,
    stages: cross.stages,
    heatRate: cross.heatRate,
    surfaceTemp: cross.surfaceTemp,
    outletTemp: inputs.inletTemp - cross.heatRate / inputs.capacityRate,
    meanFluidTemp: inputs.inletTemp,
    exactHeatRate: exact.heatRate,
  );
}

HeatTransferResult _calculateExact(TubeInputs inputs) {
  final tIn = inputs.inletTemp;
  final tInf = inputs.ambientTemp;

  var meanTemp = tIn;
  var cross = _solveCrossSection(inputs, meanTemp);
  var outletTemp = tIn;
  for (var i = 0; i < 100; i++) {
    outletTemp = outletTemperature(
      inletTemp: tIn,
      ambientTemp: tInf,
      totalResistance: totalResistanceOf(cross.stages),
      capacityRate: inputs.capacityRate,
    );
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

/// Heat transport across the tube wall at fluid temperature [tf].
({List<StageResult> stages, double heatRate, double surfaceTemp})
_solveCrossSection(TubeInputs inputs, double tf) {
  final length = inputs.length;
  final innerArea = cylinderArea(inputs.r1, length);
  final outerArea = cylinderArea(inputs.r3, length);
  final emissivity = inputs.effectiveEmissivity;

  final rInnerConv = surfaceResistance(inputs.hInner, innerArea);
  final rPipe = cylinderConductionResistance(
    inputs.r1,
    inputs.r2,
    inputs.kPipe,
    length,
  );
  final rInsulation = cylinderConductionResistance(
    inputs.r2,
    inputs.r3,
    inputs.kInsulation,
    length,
  );

  // Resistance between the fluid and the outer surface.
  final rInside = rInnerConv + rPipe + rInsulation;
  final tInf = inputs.ambientTemp;

  double convectionOut(double ts) =>
      convectionHeatFlow(inputs.hOuter, outerArea, ts, tInf);
  double radiationOut(double ts) =>
      radiationHeatFlow(emissivity, outerArea, ts, tInf);

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
  final hRad = radiationCoefficient(emissivity, ts, tInf);

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
        resistance: surfaceResistance(inputs.hOuter, outerArea),
        tIn: ts,
        tOut: tInf,
        heatRate: convectionOut(ts),
        area: outerArea,
        coefficient: inputs.hOuter,
      ),
      StageResult(
        stage: HeatStage.outerRadiation,
        resistance: surfaceResistance(hRad, outerArea),
        tIn: ts,
        tOut: tInf,
        heatRate: radiationOut(ts),
        area: outerArea,
        coefficient: hRad,
      ),
    ],
  );
}
