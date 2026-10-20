// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SEM tools';

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

  @override
  String get simplifyConstantTemperature =>
      'Constant fluid temperature (simplified)';

  @override
  String get simplifyConstantTemperatureHint =>
      'Ignore the cooling along the tube: every metre loses heat as if the fluid were at its inlet temperature.';

  @override
  String get simplifiedBadge => 'Simplified';

  @override
  String get lawSeries => 'Thermal resistances in series';

  @override
  String get stepConstantFluid =>
      'Simplified: the fluid stays at its inlet temperature along the whole tube';

  @override
  String get stepOutletEnergyBalance =>
      'Outlet temperature from the energy balance on the fluid';

  @override
  String simplificationComparison(
    String exact,
    String difference,
    String percent,
  ) {
    return 'Without the simplification (fluid cooling along the tube) the heat flow is $exact W; the simplification differs by $difference W ($percent %).';
  }

  @override
  String get simplificationInvalid =>
      'The simplification is not valid here: the fluid would pass the ambient temperature. Use the exact calculation.';

  @override
  String get navOverview => 'Overview';

  @override
  String get overviewSubtitle =>
      'Engineering calculation tools. Pick one to get started.';

  @override
  String get moduleHeatTransfer => 'Heat transport';

  @override
  String get moduleHeatTransferDescription =>
      'Heat loss and outlet temperature of an insulated tube, through convection, conduction and radiation.';

  @override
  String get modulePrice => 'Price calculation';

  @override
  String get modulePriceTitle => 'Cost of energy loss';

  @override
  String get modulePriceDescription =>
      'Cost of a heat loss over a usage period at a given energy market price.';

  @override
  String get calculation => 'Calculation';

  @override
  String get priceFieldPower => 'Heat loss';

  @override
  String get priceFieldDuration => 'Usage duration';

  @override
  String get priceFieldMarketPrice => 'Market price';

  @override
  String priceUseHeatLoss(String power, String length) {
    return 'Use heat loss from Heat transport: $power W over $length m';
  }

  @override
  String priceFromHeatTransfer(String length) {
    return 'Heat loss of $length m of tube, taken from Heat transport';
  }

  @override
  String get presetDay => 'Day';

  @override
  String get presetWeek => 'Week';

  @override
  String get presetMonth => 'Month';

  @override
  String get presetYear => 'Year';

  @override
  String get statCost => 'Cost';

  @override
  String get statEnergy => 'Energy lost';

  @override
  String get statCostPerHour => 'Cost per hour';

  @override
  String get statCostPerMetre => 'Cost per metre';

  @override
  String get lawEnergyCost => 'Energy and cost';

  @override
  String get priceStepEnergy => 'Energy lost over the usage duration';

  @override
  String get priceStepConvert => 'Converted to MWh (1 MWh = 1 000 000 Wh)';

  @override
  String get priceStepCost => 'Cost at the market price';

  @override
  String get priceStepCostPerHour => 'Cost per hour of use';

  @override
  String get priceStepCostPerMetre => 'Cost per metre of tube';

  @override
  String get symbolPower => 'Heat loss (power)';

  @override
  String get symbolDuration => 'Usage duration';

  @override
  String get symbolMarketPrice => 'Energy market price';

  @override
  String get symbolEnergy => 'Energy lost';

  @override
  String get symbolCost => 'Cost of the energy lost';

  @override
  String get sourceCode => 'Source code on GitHub';

  @override
  String get about => 'About';

  @override
  String get aboutText =>
      'SEM tools are calculation tools for the Sustainable Energy Management advanced bachelor (banaba) of Howest. Open source under the MIT license.';

  @override
  String get disclaimer =>
      'Provided as is, for educational use. No responsibility is taken for potential errors; always verify results before relying on them.';

  @override
  String get moduleExpansionTitle => 'Expansion';

  @override
  String get moduleExpansionPageTitle => 'Liquid expansion in a heat network';

  @override
  String get moduleExpansionDescription =>
      'Thermal expansion of a liquid in a heat network from the density change between cold and heated state.';

  @override
  String get expansionSectionVolume => 'System volume';

  @override
  String get expansionSectionDensity => 'Liquid density';

  @override
  String get expansionModeVolume => 'Direct volume';

  @override
  String get expansionModeTube => 'From tube (Dᵢ, L)';

  @override
  String get expansionFieldVolume => 'Initial volume';

  @override
  String get expansionFieldDensityCold => 'Cold density';

  @override
  String get expansionFieldDensityHot => 'Heated density';

  @override
  String get presetWater10 => 'Water (10 °C)';

  @override
  String get presetWater20 => 'Water (20 °C)';

  @override
  String get presetWater40 => 'Water (40 °C)';

  @override
  String get presetWater60 => 'Water (60 °C)';

  @override
  String get presetWater80 => 'Water (80 °C)';

  @override
  String get presetWater90 => 'Water (90 °C)';

  @override
  String get presetWater110 => 'Water (110 °C)';

  @override
  String get presetWater150 => 'Water (150 °C)';

  @override
  String expansionUseHeatTransferTube(String diameter, String length) {
    return 'Use tube from Heat transport: Dᵢ = $diameter mm, L = $length m';
  }

  @override
  String expansionFromHeatTransfer(String diameter, String length) {
    return 'Tube dimensions (Dᵢ = $diameter mm, L = $length m) taken from Heat transport';
  }

  @override
  String get statExpansionVolume => 'Expansion volume';

  @override
  String get statInitialVolume => 'Initial volume';

  @override
  String get statFinalVolume => 'Heated volume';

  @override
  String get statMass => 'Liquid mass';

  @override
  String get vesselColdState => 'Cold (initial)';

  @override
  String get vesselHeatedState => 'Heated (expanded)';

  @override
  String get vesselConstantMass => 'm = constant';

  @override
  String get vesselExpansion => 'Expansion';

  @override
  String get expansionInvalidDensity =>
      'The heated density ρ₂ is greater than or equal to the cold density ρ₁, so the liquid does not expand.';

  @override
  String get lawConservationOfMass => 'Conservation of mass';

  @override
  String get expansionStepRadius => 'Inner radius of the pipe';

  @override
  String get expansionStepTubeVolume =>
      'Initial liquid volume inside the cylindrical tube';

  @override
  String get expansionStepMass =>
      'Mass of the cold liquid (stays constant during heating)';

  @override
  String get expansionStepFinalVolume =>
      'Volume of the heated liquid at the lower density';

  @override
  String get expansionStepDeltaV => 'Volume expansion of the liquid';

  @override
  String get expansionStepConvertLitres =>
      'Converted to litres (1 m³ = 1 000 L)';

  @override
  String get symbolInitialVolume => 'Initial liquid volume (cold)';

  @override
  String get symbolFinalVolume => 'Final liquid volume (heated)';

  @override
  String get symbolExpansionVolume => 'Volume expansion of the liquid';

  @override
  String get symbolDensityCold => 'Liquid density in the cold state';

  @override
  String get symbolDensityHot => 'Liquid density in the heated state';

  @override
  String get symbolMass => 'Mass of the liquid in the network';

  @override
  String get moduleSteamTitle => 'Steam';

  @override
  String get moduleSteamPageTitle => 'Steam generation & T–h diagram';

  @override
  String get moduleSteamDescription =>
      'Required heat to turn liquid water into (superheated) steam at a given pressure, visualised in a temperature–enthalpy diagram.';

  @override
  String get steamSectionConditions => 'Pressure & temperatures';

  @override
  String get steamSectionFlow => 'Steam flow rate (optional)';

  @override
  String get steamFieldPressure => 'Absolute pressure';

  @override
  String get steamFieldStartTemp => 'Initial liquid temp.';

  @override
  String get steamFieldSteamTemp => 'Target steam temp.';

  @override
  String get steamFieldFlowRate => 'Steam flow rate';

  @override
  String steamTableSummary(
    String pressure,
    String pressureKpa,
    String tSat,
    String hf,
    String hfg,
    String hg,
  ) {
    return 'Table A-5 at P = $pressure bar ($pressureKpa kPa): Tₛₐₜ = $tSat °C, h_f = $hf kJ/kg, h_fg = $hfg kJ/kg, h_g = $hg kJ/kg';
  }

  @override
  String get steamIncludeFlow =>
      'Include steam flow rate (calculate power in kW)';

  @override
  String get steamUnitTonPerHour => 'ton/h';

  @override
  String get steamUnitKgPerSecond => 'kg/s';

  @override
  String get presetAtmospheric => 'Atmospheric (1.013 bar)';

  @override
  String get presetLowPressureSteam => 'Low pressure (2 bar)';

  @override
  String get presetMediumPressureSteam => 'Medium pressure (5 bar)';

  @override
  String get presetIndustrialSteam => 'Industrial (10 bar)';

  @override
  String get presetHighPressureSteam => 'High pressure (20 bar)';

  @override
  String get presetPowerPlantSteam => 'Power plant (40 bar)';

  @override
  String get presetBoilingPoint => 'Saturated steam (Tₛₐₜ)';

  @override
  String get stageLiquidHeating => 'Liquid heating';

  @override
  String get stageLiquidHeatingPath =>
      'Subcooled water T₁ → saturated water Tₛₐₜ (Table A-4 & A-5)';

  @override
  String get stageEvaporation => 'Evaporation (boiling)';

  @override
  String get stageEvaporationPath =>
      'Phase change at constant Tₛₐₜ (Table A-5)';

  @override
  String get stageSuperheating => 'Superheating';

  @override
  String get stageSuperheatingPath =>
      'Saturated steam Tₛₐₜ → superheated steam T₂ (Table A-6)';

  @override
  String steamTotalPath(String pressure) {
    return 'Liquid water T₁ → steam T₂ at P = $pressure bar';
  }

  @override
  String get statSpecificHeatTotal => 'Required heat q';

  @override
  String get statBoilingTemperature => 'Boiling point Tₛₐₜ';

  @override
  String get statDegreeOfSuperheat => 'Superheat ΔTₛᵤₚ';

  @override
  String get statThermalPower => 'Thermal power Q̇';

  @override
  String get statStageSpecificHeat => 'Required heat';

  @override
  String get statShareOfTotal => 'Share of total';

  @override
  String get diagramAxisTemp => 'T [°C]';

  @override
  String get diagramAxisEnthalpy => 'h [kJ/kg]';

  @override
  String get diagramSaturatedLiquid => 'Saturated liquid';

  @override
  String get diagramSaturatedSteam => 'Saturated steam';

  @override
  String get diagramWetSteam => 'Two-phase (wet steam)';

  @override
  String diagramIsobar(String pressure) {
    return 'P = $pressure bar';
  }

  @override
  String steamStartAboveBoiling(String t1, String tSat, String pressure) {
    return 'The initial temperature T₁ ($t1 °C) is above the boiling point Tₛₐₜ ($tSat °C) at $pressure bar — water is already past the liquid phase.';
  }

  @override
  String steamTargetBelowBoiling(String t2, String tSat, String pressure) {
    return 'The target steam temperature T₂ ($t2 °C) is below the boiling point Tₛₐₜ ($tSat °C) at $pressure bar — water has not reached the boiling point yet.';
  }

  @override
  String steamSaturatedNote(String tSat) {
    return 'T₂ equals the boiling temperature Tₛₐₜ ($tSat °C): the steam is dry saturated (h₂ = h_g, so q₃ = 0 kJ/kg).';
  }

  @override
  String get lawSensibleHeat => 'Sensible heat (Table A-4 & A-5)';

  @override
  String get lawLatentHeat => 'Latent heat of vaporisation (Table A-5)';

  @override
  String get lawSuperheat => 'Superheating enthalpy (Table A-6)';

  @override
  String get lawIsobaricEnthalpy =>
      'Isobaric enthalpy balance (Tables A-4, A-5 & A-6)';

  @override
  String get steamStepH1 =>
      'Table A-4 — Initial liquid enthalpy at T₁ (compressed liquid approximation h₁ ≈ h_f(T₁))';

  @override
  String get steamStepHf =>
      'Table A-5 — Saturated liquid enthalpy and boiling point at pressure P';

  @override
  String get steamStepLiquidHeat =>
      'Heat required to bring the subcooled liquid to the boiling point';

  @override
  String get steamStepEvaporation =>
      'Table A-5 — Latent heat of vaporisation at constant boiling temperature Tₛₐₜ';

  @override
  String get steamStepH2 =>
      'Table A-6 — Superheated steam enthalpy at pressure P and temperature T₂';

  @override
  String get steamStepSuperheat =>
      'Heat required to superheat the saturated steam from Tₛₐₜ to T₂';

  @override
  String get steamStepTotalSpecific =>
      'Total specific heat transfer from start liquid to final steam';

  @override
  String get steamStepMassFlowConvert =>
      'Convert steam flow rate from ton/h to kg/s (1 ton = 1 000 kg, 1 h = 3 600 s)';

  @override
  String get steamStepThermalPower =>
      'Thermal power required for steam mass flow rate ṁ';

  @override
  String get symbolSpecificHeatTotal => 'Total specific heat transfer';

  @override
  String get symbolSpecificHeatLiquid =>
      'Heat for heating liquid water to boiling';

  @override
  String get symbolSpecificHeatEvap => 'Latent heat of vaporisation';

  @override
  String get symbolSpecificHeatSuper => 'Heat for superheating steam';

  @override
  String get symbolEnthalpyStart =>
      'Enthalpy of initial liquid water (Table A-4 at T₁)';

  @override
  String get symbolEnthalpySatLiquid =>
      'Enthalpy of saturated liquid at pressure P (Table A-5)';

  @override
  String get symbolEnthalpySatVapour =>
      'Enthalpy of saturated steam at pressure P (Table A-5)';

  @override
  String get symbolEnthalpySteam =>
      'Enthalpy of final steam at P and T₂ (Table A-6)';

  @override
  String get symbolPressure => 'Absolute steam pressure';

  @override
  String get symbolStartTemp => 'Initial liquid water temperature';

  @override
  String get symbolBoilingTemp =>
      'Saturation (boiling) temperature at pressure P';

  @override
  String get symbolSteamTemp => 'Final (target) steam temperature';

  @override
  String get symbolSteamFlow => 'Steam mass flow rate';

  @override
  String get symbolThermalPower => 'Thermal power';

  @override
  String get pointStartLiquid => 'Start liquid (Table A-4)';

  @override
  String get pointSaturatedLiquid =>
      'Saturated liquid — boiling starts (Table A-5)';

  @override
  String get pointSaturatedSteam =>
      'Saturated steam — boiling complete (Table A-5)';

  @override
  String get pointEndSteam => 'Superheated steam — endpoint (Table A-6)';
}
