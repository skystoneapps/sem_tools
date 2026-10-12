// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Heat transport';

  @override
  String get screenTitle => 'Heat transport in an insulated tube';

  @override
  String get resetTooltip => 'Reset to defaults';

  @override
  String get languageTooltip => 'Language';

  @override
  String get tabTubeAndVariables => 'Tube & variables';

  @override
  String get tabDetails => 'Details';

  @override
  String get mechanismConvection => 'Convection';

  @override
  String get mechanismConduction => 'Conduction';

  @override
  String get mechanismRadiation => 'Radiation';

  @override
  String get lawNewton => 'Newton\'s Law of Cooling';

  @override
  String get lawFourier => 'Fourier\'s Law';

  @override
  String get lawStefanBoltzmann => 'Stefan–Boltzmann Law';

  @override
  String get stageInnerConvection => 'Inner convection';

  @override
  String get stageInnerConvectionPath => 'Fluid → inner pipe wall';

  @override
  String get stagePipeConduction => 'Pipe wall conduction';

  @override
  String get stagePipeConductionPath => 'Through the pipe wall';

  @override
  String get stageInsulationConduction => 'Insulation conduction';

  @override
  String get stageInsulationConductionPath => 'Through the insulation layer';

  @override
  String get stageOuterConvection => 'Outer convection';

  @override
  String get stageOuterConvectionPath => 'Outer surface → ambient air';

  @override
  String get stageOuterRadiation => 'Surface radiation';

  @override
  String get stageOuterRadiationPath => 'Outer surface → surroundings';

  @override
  String get total => 'Total';

  @override
  String get totalSubtitle => 'How the stages combine';

  @override
  String get totalPath => 'Fluid → surroundings';

  @override
  String get statHeatFlow => 'Heat flow';

  @override
  String get statResistance => 'Resistance';

  @override
  String get statTemperatureDrop => 'Temperature drop';

  @override
  String get statTotalResistance => 'Total resistance';

  @override
  String get stepParallel =>
      'Convection and radiation act in parallel at the surface';

  @override
  String get stepSeries => 'The other stages are in series with it';

  @override
  String get stepTotalHeatFlow => 'Total heat flow';

  @override
  String get stepHeatFlowPerMetre => 'Heat flow per metre of tube';

  @override
  String get stepInnerArea => 'Area of the inner pipe wall';

  @override
  String get stepThermalResistance => 'Thermal resistance';

  @override
  String get stepInnerHeatFlow => 'Heat flow from the fluid into the wall';

  @override
  String get stepInnerWallTemperature => 'Inner wall temperature';

  @override
  String get stepIntegratedWall =>
      'Integrated over the cylindrical wall, with A(r) = 2πrL';

  @override
  String get stepWallHeatFlow => 'Heat flow through the wall';

  @override
  String get stepOuterPipeTemperature => 'Outer pipe temperature';

  @override
  String get stepIntegratedLayer =>
      'Integrated over the cylindrical layer, with A(r) = 2πrL';

  @override
  String get stepInsulationHeatFlow => 'Heat flow through the insulation';

  @override
  String get stepSurfaceTemperature => 'Outer surface temperature';

  @override
  String get stepOuterArea => 'Area of the outer surface';

  @override
  String get stepConvectionHeatFlow => 'Heat carried away by the air';

  @override
  String get stepAbsoluteTemperatures =>
      'Radiation needs absolute temperatures';

  @override
  String get stepRadiatedHeat => 'Heat radiated to the surroundings';

  @override
  String get stepLinearisedCoefficient => 'Linearised radiation coefficient';

  @override
  String get stepEquivalentResistance => 'Equivalent thermal resistance';

  @override
  String get surfaceIterationNote =>
      'T_s is not known in advance: it is solved iteratively so that the heat arriving at the surface equals the heat leaving it by convection and radiation together.';

  @override
  String get variables => 'Variables';

  @override
  String get sectionTemperatures => 'Temperatures';

  @override
  String get sectionGeometry => 'Geometry';

  @override
  String get sectionMaterials => 'Materials';

  @override
  String get sectionSurfaces => 'Surfaces';

  @override
  String get fieldAmbientTemperature => 'Ambient';

  @override
  String get fieldLength => 'Tube length';

  @override
  String get fieldInnerDiameter => 'Inner diameter';

  @override
  String get fieldWallThickness => 'Wall thickness';

  @override
  String get fieldInsulationThickness => 'Insulation';

  @override
  String get fieldPipeConductivity => 'Pipe conductivity';

  @override
  String get fieldInsulationConductivity => 'Insulation conductivity';

  @override
  String get fieldInnerConvection => 'Inner convection';

  @override
  String get fieldOuterConvection => 'Outer convection';

  @override
  String get fieldEmissivity => 'Surface emissivity';

  @override
  String get presetsTooltip => 'Presets';

  @override
  String get errorEnterNumber => 'Enter a number';

  @override
  String get presetCarbonSteel => 'Carbon steel';

  @override
  String get presetStainlessSteel => 'Stainless steel';

  @override
  String get presetCopper => 'Copper';

  @override
  String get presetAluminium => 'Aluminium';

  @override
  String get presetPvc => 'PVC';

  @override
  String get presetMineralWool => 'Mineral wool';

  @override
  String get presetPolyurethaneFoam => 'Polyurethane foam';

  @override
  String get presetElastomericFoam => 'Elastomeric foam';

  @override
  String get presetCalciumSilicate => 'Calcium silicate';

  @override
  String get presetAerogelBlanket => 'Aerogel blanket';

  @override
  String get presetGasForced => 'Gas, forced flow';

  @override
  String get presetOilForced => 'Oil, forced flow';

  @override
  String get presetWaterForced => 'Water, forced flow';

  @override
  String get presetWaterTurbulent => 'Water, turbulent';

  @override
  String get presetCondensingSteam => 'Condensing steam';

  @override
  String get presetStillAir => 'Still air';

  @override
  String get presetIndoorAir => 'Indoor air';

  @override
  String get presetLightWind => 'Light wind';

  @override
  String get presetStrongWind => 'Strong wind';

  @override
  String get presetPolishedAluminium => 'Polished aluminium';

  @override
  String get presetOxidisedAluminium => 'Oxidised aluminium';

  @override
  String get presetStainlessJacket => 'Stainless steel jacket';

  @override
  String get presetPvcJacket => 'PVC jacket';

  @override
  String get presetPaintedSurface => 'Painted surface';

  @override
  String get tubeAmbient => 'Ambient';

  @override
  String get tubeOuterSurface => 'outer surface';

  @override
  String get tubePipeWall => 'Pipe wall';

  @override
  String get tubeInsulation => 'Insulation';

  @override
  String get results => 'Results';

  @override
  String get resultsStage => 'Stage';

  @override
  String get inParallel => 'in parallel';

  @override
  String errorGreaterThan(String value) {
    return 'Must be > $value';
  }

  @override
  String errorAtLeast(String value) {
    return 'Must be ≥ $value';
  }

  @override
  String errorAtMost(String value) {
    return 'Must be ≤ $value';
  }

  @override
  String resultsTubeLength(String length) {
    return 'over $length m of tube';
  }

  @override
  String get symbolHeatFlow => 'Heat flow';

  @override
  String get symbolHeatFlowConvection =>
      'Heat carried away by outer convection';

  @override
  String get symbolHeatFlowRadiation => 'Heat radiated by the outer surface';

  @override
  String get symbolHeatFlowPerMetre => 'Heat flow per metre of tube';

  @override
  String get symbolAreaInner => 'Inner surface area of the pipe';

  @override
  String get symbolAreaOuter => 'Outer surface area of the insulation';

  @override
  String get symbolConvectionCoefficientInner =>
      'Convection coefficient on the fluid side';

  @override
  String get symbolConvectionCoefficientOuter =>
      'Convection coefficient on the air side';

  @override
  String get symbolRadiationCoefficient => 'Linearised radiation coefficient';

  @override
  String get symbolConductivityPipe => 'Thermal conductivity of the pipe wall';

  @override
  String get symbolConductivityInsulation =>
      'Thermal conductivity of the insulation';

  @override
  String get symbolAmbientTemperature => 'Ambient temperature';

  @override
  String get symbolSurfaceTemperature => 'Outer surface temperature';

  @override
  String get symbolInnerWallTemperature => 'Temperature of the inner pipe wall';

  @override
  String get symbolInterfaceTemperature =>
      'Temperature between pipe and insulation';

  @override
  String get symbolTemperatureDifference =>
      'Temperature difference across the stage';

  @override
  String get symbolTemperatureGradient =>
      'Temperature gradient in the radial direction';

  @override
  String get symbolRadius => 'Radius';

  @override
  String get symbolRadiusInner => 'Inner radius of the pipe';

  @override
  String get symbolRadiusPipe => 'Outer radius of the pipe';

  @override
  String get symbolRadiusOuter => 'Outer radius of the insulation';

  @override
  String get symbolLength => 'Tube length';

  @override
  String get symbolResistance => 'Thermal resistance';

  @override
  String get symbolResistanceInnerConvection =>
      'Thermal resistance of inner convection';

  @override
  String get symbolResistancePipe => 'Thermal resistance of the pipe wall';

  @override
  String get symbolResistanceInsulation =>
      'Thermal resistance of the insulation';

  @override
  String get symbolResistanceOuterConvection =>
      'Thermal resistance of outer convection';

  @override
  String get symbolResistanceRadiation =>
      'Thermal resistance of surface radiation';

  @override
  String get symbolResistanceOuter =>
      'Combined resistance at the outer surface: convection and radiation in parallel';

  @override
  String get symbolResistanceTotal =>
      'Total thermal resistance from fluid to surroundings';

  @override
  String get symbolEmissivity =>
      'Emissivity of the outer surface, from 0 (mirror) to 1 (black body)';

  @override
  String get symbolStefanBoltzmann => 'Stefan–Boltzmann constant';

  @override
  String get fieldInletTemperature => 'Fluid inlet';

  @override
  String get sectionFlow => 'Flow';

  @override
  String get fieldMassFlow => 'Mass flow rate';

  @override
  String get fieldSpecificHeat => 'Specific heat';

  @override
  String get presetWater => 'Water';

  @override
  String get presetThermalOil => 'Thermal oil';

  @override
  String get presetGlycol => 'Water/glycol 50 %';

  @override
  String get presetAir => 'Air';

  @override
  String get presetSteam => 'Superheated steam';

  @override
  String get tubeInlet => 'Inlet';

  @override
  String get tubeOutlet => 'Outlet';

  @override
  String get where => 'where';

  @override
  String get lawEnergyBalance => 'Energy balance on the fluid';

  @override
  String get stepOutletTemperature =>
      'Along the tube, the fluid temperature approaches ambient exponentially';

  @override
  String get stepMeanTemperature =>
      'Logarithmic mean fluid temperature, used for every stage';

  @override
  String get stepCheck =>
      'Check: the same heat flow through the thermal resistances';

  @override
  String get statInletTemperature => 'Inlet temperature';

  @override
  String get statOutletTemperature => 'Outlet temperature';

  @override
  String get statFluidChange => 'Change along the tube';

  @override
  String get symbolInletTemperature => 'Fluid temperature at the inlet';

  @override
  String get symbolOutletTemperature =>
      'Fluid temperature at the outlet (end of the tube)';

  @override
  String get symbolMeanFluidTemperature => 'Logarithmic mean fluid temperature';

  @override
  String get symbolMassFlow => 'Mass flow rate of the fluid';

  @override
  String get symbolSpecificHeat => 'Specific heat capacity of the fluid';

  @override
  String get ignoreRadiation => 'Ignore radiation';

  @override
  String get includeRadiation => 'Include radiation';

  @override
  String get radiationIgnored => 'Radiation is ignored in the calculation.';

  @override
  String get stepOnlyConvection =>
      'Radiation is ignored, so only convection acts at the surface';
}
