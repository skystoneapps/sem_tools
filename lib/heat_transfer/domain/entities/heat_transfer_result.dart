import '../physics.dart';
import 'heat_stage.dart';
import 'tube_inputs.dart';

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
    this.exactHeatRate,
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

  /// Fluid temperature at which the stages are evaluated: the logarithmic
  /// mean between inlet and outlet, or the inlet temperature when
  /// [simplified].
  final double meanFluidTemp;

  /// With the simplification, the heat flow of the exact calculation, to
  /// show how much the simplification differs. `null` otherwise.
  final double? exactHeatRate;

  bool get simplified => inputs.constantFluidTemp;

  /// The simplification breaks down when the fluid would cool (or heat) past
  /// the ambient temperature.
  bool get simplificationValid =>
      (outletTemp - ambientTemp) * (inletTemp - ambientTemp) >= 0;

  double get inletTemp => inputs.inletTemp;
  double get ambientTemp => inputs.ambientTemp;

  StageResult operator [](HeatStage stage) =>
      stages.firstWhere((s) => s.stage == stage);

  double get heatRatePerMetre => heatRate / inputs.length;

  /// Combined resistance of the parallel outer convection and radiation.
  double get outerResistance => outerResistanceOf(stages);

  double get totalResistance => totalResistanceOf(stages);
}

/// Resistance at the outer surface, where convection and radiation act in
/// parallel. [stages] must be in [HeatStage] order.
double outerResistanceOf(List<StageResult> stages) => parallelResistance(
  stages[HeatStage.outerConvection.index].resistance,
  stages[HeatStage.outerRadiation.index].resistance,
);

/// Resistance from the fluid to the surroundings: the wall stages in series
/// with the outer surface. [stages] must be in [HeatStage] order.
double totalResistanceOf(List<StageResult> stages) =>
    stages[HeatStage.innerConvection.index].resistance +
    stages[HeatStage.pipeConduction.index].resistance +
    stages[HeatStage.insulationConduction.index].resistance +
    outerResistanceOf(stages);
