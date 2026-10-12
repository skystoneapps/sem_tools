import '../../l10n/app_localizations.dart';
import '../domain/heat_model.dart';

/// Localised display names for the model enums.
extension MechanismLabels on Mechanism {
  String label(AppLocalizations l10n) => switch (this) {
    Mechanism.convection => l10n.mechanismConvection,
    Mechanism.conduction => l10n.mechanismConduction,
    Mechanism.radiation => l10n.mechanismRadiation,
  };

  String law(AppLocalizations l10n) => switch (this) {
    Mechanism.convection => l10n.lawNewton,
    Mechanism.conduction => l10n.lawFourier,
    Mechanism.radiation => l10n.lawStefanBoltzmann,
  };
}

extension HeatStageLabels on HeatStage {
  String title(AppLocalizations l10n) => switch (this) {
    HeatStage.innerConvection => l10n.stageInnerConvection,
    HeatStage.pipeConduction => l10n.stagePipeConduction,
    HeatStage.insulationConduction => l10n.stageInsulationConduction,
    HeatStage.outerConvection => l10n.stageOuterConvection,
    HeatStage.outerRadiation => l10n.stageOuterRadiation,
  };

  /// Where the heat goes in this stage, e.g. "Fluid → inner pipe wall".
  String path(AppLocalizations l10n) => switch (this) {
    HeatStage.innerConvection => l10n.stageInnerConvectionPath,
    HeatStage.pipeConduction => l10n.stagePipeConductionPath,
    HeatStage.insulationConduction => l10n.stageInsulationConductionPath,
    HeatStage.outerConvection => l10n.stageOuterConvectionPath,
    HeatStage.outerRadiation => l10n.stageOuterRadiationPath,
  };
}
