// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Warmtetransport';

  @override
  String get screenTitle => 'Warmtetransport in een geïsoleerde buis';

  @override
  String get resetTooltip => 'Standaardwaarden herstellen';

  @override
  String get languageTooltip => 'Taal';

  @override
  String get tabTubeAndVariables => 'Buis & variabelen';

  @override
  String get tabDetails => 'Details';

  @override
  String get mechanismConvection => 'Convectie';

  @override
  String get mechanismConduction => 'Geleiding';

  @override
  String get mechanismRadiation => 'Straling';

  @override
  String get lawNewton => 'Afkoelingswet van Newton';

  @override
  String get lawFourier => 'Wet van Fourier';

  @override
  String get lawStefanBoltzmann => 'Wet van Stefan-Boltzmann';

  @override
  String get stageInnerConvection => 'Inwendige convectie';

  @override
  String get stageInnerConvectionPath => 'Medium → binnenwand buis';

  @override
  String get stagePipeConduction => 'Geleiding door buiswand';

  @override
  String get stagePipeConductionPath => 'Door de buiswand';

  @override
  String get stageInsulationConduction => 'Geleiding door isolatie';

  @override
  String get stageInsulationConductionPath => 'Door de isolatielaag';

  @override
  String get stageOuterConvection => 'Uitwendige convectie';

  @override
  String get stageOuterConvectionPath => 'Buitenoppervlak → omgevingslucht';

  @override
  String get stageOuterRadiation => 'Oppervlaktestraling';

  @override
  String get stageOuterRadiationPath => 'Buitenoppervlak → omgeving';

  @override
  String get total => 'Totaal';

  @override
  String get totalSubtitle => 'Hoe de stappen samenwerken';

  @override
  String get totalPath => 'Medium → omgeving';

  @override
  String get statHeatFlow => 'Warmtestroom';

  @override
  String get statResistance => 'Weerstand';

  @override
  String get statTemperatureDrop => 'Temperatuurdaling';

  @override
  String get statTotalResistance => 'Totale weerstand';

  @override
  String get lawSeries => 'Thermische weerstanden in serie';

  @override
  String get stepParallel =>
      'Convectie en straling werken parallel aan het oppervlak';

  @override
  String get stepSeries => 'De andere stappen staan daarmee in serie';

  @override
  String get stepTotalHeatFlow => 'Totale warmtestroom';

  @override
  String get stepHeatFlowPerMetre => 'Warmtestroom per meter buis';

  @override
  String get stepInnerArea => 'Oppervlakte van de binnenwand';

  @override
  String get stepThermalResistance => 'Thermische weerstand';

  @override
  String get stepInnerHeatFlow => 'Warmtestroom van het medium naar de wand';

  @override
  String get stepInnerWallTemperature => 'Temperatuur van de binnenwand';

  @override
  String get stepIntegratedWall =>
      'Geïntegreerd over de cilindrische wand, met A(r) = 2πrL';

  @override
  String get stepWallHeatFlow => 'Warmtestroom door de wand';

  @override
  String get stepOuterPipeTemperature =>
      'Temperatuur aan de buitenzijde van de buis';

  @override
  String get stepIntegratedLayer =>
      'Geïntegreerd over de cilindrische laag, met A(r) = 2πrL';

  @override
  String get stepInsulationHeatFlow => 'Warmtestroom door de isolatie';

  @override
  String get stepSurfaceTemperature => 'Temperatuur van het buitenoppervlak';

  @override
  String get stepOuterArea => 'Oppervlakte van het buitenoppervlak';

  @override
  String get stepConvectionHeatFlow => 'Warmte afgevoerd door de lucht';

  @override
  String get stepAbsoluteTemperatures =>
      'Straling vereist absolute temperaturen';

  @override
  String get stepRadiatedHeat => 'Warmte uitgestraald naar de omgeving';

  @override
  String get stepLinearisedCoefficient =>
      'Gelineariseerde stralingscoëfficiënt';

  @override
  String get stepEquivalentResistance => 'Equivalente thermische weerstand';

  @override
  String get surfaceIterationNote =>
      'T_s is vooraf niet bekend: ze wordt iteratief bepaald zodat de warmte die het oppervlak bereikt gelijk is aan de warmte die het samen via convectie en straling verlaat.';

  @override
  String get variables => 'Variabelen';

  @override
  String get sectionTemperatures => 'Temperaturen';

  @override
  String get sectionGeometry => 'Geometrie';

  @override
  String get sectionMaterials => 'Materialen';

  @override
  String get sectionSurfaces => 'Oppervlakken';

  @override
  String get fieldFluidTemperature => 'Medium';

  @override
  String get fieldAmbientTemperature => 'Omgeving';

  @override
  String get fieldLength => 'Buislengte';

  @override
  String get fieldInnerDiameter => 'Binnendiameter';

  @override
  String get fieldWallThickness => 'Wanddikte';

  @override
  String get fieldInsulationThickness => 'Isolatie';

  @override
  String get fieldPipeConductivity => 'Geleidbaarheid buis';

  @override
  String get fieldInsulationConductivity => 'Geleidbaarheid isolatie';

  @override
  String get fieldInnerConvection => 'Inwendige convectie';

  @override
  String get fieldOuterConvection => 'Uitwendige convectie';

  @override
  String get fieldEmissivity => 'Emissiviteit oppervlak';

  @override
  String get presetsTooltip => 'Voorinstellingen';

  @override
  String get errorEnterNumber => 'Voer een getal in';

  @override
  String get presetCarbonSteel => 'Koolstofstaal';

  @override
  String get presetStainlessSteel => 'Roestvast staal';

  @override
  String get presetCopper => 'Koper';

  @override
  String get presetAluminium => 'Aluminium';

  @override
  String get presetPvc => 'PVC';

  @override
  String get presetMineralWool => 'Minerale wol';

  @override
  String get presetPolyurethaneFoam => 'Polyurethaanschuim';

  @override
  String get presetElastomericFoam => 'Elastomeerschuim';

  @override
  String get presetCalciumSilicate => 'Calciumsilicaat';

  @override
  String get presetAerogelBlanket => 'Aerogeldeken';

  @override
  String get presetGasForced => 'Gas, geforceerde stroming';

  @override
  String get presetOilForced => 'Olie, geforceerde stroming';

  @override
  String get presetWaterForced => 'Water, geforceerde stroming';

  @override
  String get presetWaterTurbulent => 'Water, turbulent';

  @override
  String get presetCondensingSteam => 'Condenserende stoom';

  @override
  String get presetStillAir => 'Stilstaande lucht';

  @override
  String get presetIndoorAir => 'Binnenlucht';

  @override
  String get presetLightWind => 'Lichte wind';

  @override
  String get presetStrongWind => 'Harde wind';

  @override
  String get presetPolishedAluminium => 'Gepolijst aluminium';

  @override
  String get presetOxidisedAluminium => 'Geoxideerd aluminium';

  @override
  String get presetStainlessJacket => 'Mantel van roestvast staal';

  @override
  String get presetPvcJacket => 'PVC-mantel';

  @override
  String get presetPaintedSurface => 'Geverfd oppervlak';

  @override
  String get tubeAmbient => 'Omgeving';

  @override
  String get tubeOuterSurface => 'buitenoppervlak';

  @override
  String get tubeFluid => 'Medium';

  @override
  String get tubePipeWall => 'Buiswand';

  @override
  String get tubeInsulation => 'Isolatie';

  @override
  String get results => 'Resultaten';

  @override
  String get resultsStage => 'Stap';

  @override
  String get inParallel => 'parallel';

  @override
  String errorGreaterThan(String value) {
    return 'Moet > $value zijn';
  }

  @override
  String errorAtLeast(String value) {
    return 'Moet ≥ $value zijn';
  }

  @override
  String errorAtMost(String value) {
    return 'Moet ≤ $value zijn';
  }

  @override
  String resultsTubeLength(String length) {
    return 'over $length m buis';
  }

  @override
  String get symbolHeatFlow => 'Warmtestroom';

  @override
  String get symbolHeatFlowConvection =>
      'Warmte afgevoerd door uitwendige convectie';

  @override
  String get symbolHeatFlowRadiation =>
      'Warmte uitgestraald door het buitenoppervlak';

  @override
  String get symbolHeatFlowPerMetre => 'Warmtestroom per meter buis';

  @override
  String get symbolArea => 'Warmteoverdragend oppervlak';

  @override
  String get symbolAreaInner => 'Binnenoppervlak van de buis';

  @override
  String get symbolAreaOuter => 'Buitenoppervlak van de isolatie';

  @override
  String get symbolConvectionCoefficient =>
      'Warmteoverdrachtscoëfficiënt voor convectie';

  @override
  String get symbolConvectionCoefficientInner =>
      'Convectiecoëfficiënt aan de mediumzijde';

  @override
  String get symbolConvectionCoefficientOuter =>
      'Convectiecoëfficiënt aan de luchtzijde';

  @override
  String get symbolRadiationCoefficient =>
      'Gelineariseerde stralingscoëfficiënt';

  @override
  String get symbolConductivity => 'Warmtegeleidingscoëfficiënt';

  @override
  String get symbolConductivityPipe =>
      'Warmtegeleidingscoëfficiënt van de buiswand';

  @override
  String get symbolConductivityInsulation =>
      'Warmtegeleidingscoëfficiënt van de isolatie';

  @override
  String get symbolFluidTemperature => 'Temperatuur van het medium';

  @override
  String get symbolAmbientTemperature => 'Omgevingstemperatuur';

  @override
  String get symbolSurfaceTemperature => 'Temperatuur van het buitenoppervlak';

  @override
  String get symbolInnerWallTemperature =>
      'Temperatuur van de binnenwand van de buis';

  @override
  String get symbolInterfaceTemperature =>
      'Temperatuur tussen buis en isolatie';

  @override
  String get symbolSurroundingsTemperature => 'Temperatuur van de omgeving';

  @override
  String get symbolTemperatureDifference => 'Temperatuurverschil over de stap';

  @override
  String get symbolTemperatureGradient =>
      'Temperatuurgradiënt in radiale richting';

  @override
  String get symbolRadius => 'Straal';

  @override
  String get symbolRadiusInner => 'Binnenstraal van de buis';

  @override
  String get symbolRadiusPipe => 'Buitenstraal van de buis';

  @override
  String get symbolRadiusOuter => 'Buitenstraal van de isolatie';

  @override
  String get symbolLength => 'Buislengte';

  @override
  String get symbolResistance => 'Thermische weerstand';

  @override
  String get symbolResistanceInnerConvection =>
      'Thermische weerstand van de inwendige convectie';

  @override
  String get symbolResistancePipe => 'Thermische weerstand van de buiswand';

  @override
  String get symbolResistanceInsulation =>
      'Thermische weerstand van de isolatie';

  @override
  String get symbolResistanceOuterConvection =>
      'Thermische weerstand van de uitwendige convectie';

  @override
  String get symbolResistanceRadiation =>
      'Thermische weerstand van de oppervlaktestraling';

  @override
  String get symbolResistanceOuter =>
      'Gecombineerde weerstand aan het buitenoppervlak: convectie en straling parallel';

  @override
  String get symbolResistanceTotal =>
      'Totale thermische weerstand van medium tot omgeving';

  @override
  String get symbolEmissivity =>
      'Emissiviteit van het buitenoppervlak, van 0 (spiegel) tot 1 (zwart lichaam)';

  @override
  String get symbolStefanBoltzmann => 'Constante van Stefan-Boltzmann';
}
