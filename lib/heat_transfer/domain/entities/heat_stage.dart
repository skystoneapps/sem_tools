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
