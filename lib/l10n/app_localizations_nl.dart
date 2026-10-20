// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'SEM tools';

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
  String get mechanismConduction => 'Conductie';

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
  String get stagePipeConduction => 'Conductie door buiswand';

  @override
  String get stagePipeConductionPath => 'Door de buiswand';

  @override
  String get stageInsulationConduction => 'Conductie door isolatie';

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
  String get symbolAreaInner => 'Binnenoppervlak van de buis';

  @override
  String get symbolAreaOuter => 'Buitenoppervlak van de isolatie';

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
  String get symbolConductivityPipe =>
      'Warmtegeleidingscoëfficiënt van de buiswand';

  @override
  String get symbolConductivityInsulation =>
      'Warmtegeleidingscoëfficiënt van de isolatie';

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

  @override
  String get fieldInletTemperature => 'Inlaat medium';

  @override
  String get sectionFlow => 'Stroming';

  @override
  String get fieldMassFlow => 'Massadebiet';

  @override
  String get fieldSpecificHeat => 'Soortelijke warmte';

  @override
  String get presetWater => 'Water';

  @override
  String get presetThermalOil => 'Thermische olie';

  @override
  String get presetGlycol => 'Water/glycol 50 %';

  @override
  String get presetAir => 'Lucht';

  @override
  String get presetSteam => 'Oververhitte stoom';

  @override
  String get tubeInlet => 'Inlaat';

  @override
  String get tubeOutlet => 'Uitlaat';

  @override
  String get where => 'waarbij';

  @override
  String get lawEnergyBalance => 'Energiebalans van het medium';

  @override
  String get stepOutletTemperature =>
      'Langs de buis nadert de temperatuur van het medium exponentieel de omgevingstemperatuur';

  @override
  String get stepMeanTemperature =>
      'Logaritmisch gemiddelde temperatuur van het medium, gebruikt voor elke stap';

  @override
  String get stepCheck =>
      'Controle: dezelfde warmtestroom door de thermische weerstanden';

  @override
  String get statInletTemperature => 'Inlaattemperatuur';

  @override
  String get statOutletTemperature => 'Uitlaattemperatuur';

  @override
  String get statFluidChange => 'Verandering langs de buis';

  @override
  String get symbolInletTemperature =>
      'Temperatuur van het medium aan de inlaat';

  @override
  String get symbolOutletTemperature =>
      'Temperatuur van het medium aan de uitlaat (einde van de buis)';

  @override
  String get symbolMeanFluidTemperature =>
      'Logaritmisch gemiddelde temperatuur van het medium';

  @override
  String get symbolMassFlow => 'Massadebiet van het medium';

  @override
  String get symbolSpecificHeat =>
      'Soortelijke warmtecapaciteit van het medium';

  @override
  String get ignoreRadiation => 'Straling negeren';

  @override
  String get includeRadiation => 'Straling meenemen';

  @override
  String get radiationIgnored => 'Straling wordt genegeerd in de berekening.';

  @override
  String get stepOnlyConvection =>
      'Straling wordt genegeerd, dus alleen convectie werkt aan het oppervlak';

  @override
  String get simplifyConstantTemperature =>
      'Constante temperatuur van het medium (vereenvoudigd)';

  @override
  String get simplifyConstantTemperatureHint =>
      'Negeer de afkoeling langs de buis: elke meter verliest warmte alsof het medium op de inlaattemperatuur is.';

  @override
  String get simplifiedBadge => 'Vereenvoudigd';

  @override
  String get lawSeries => 'Thermische weerstanden in serie';

  @override
  String get stepConstantFluid =>
      'Vereenvoudigd: het medium blijft over de hele buis op de inlaattemperatuur';

  @override
  String get stepOutletEnergyBalance =>
      'Uitlaattemperatuur uit de energiebalans van het medium';

  @override
  String simplificationComparison(
    String exact,
    String difference,
    String percent,
  ) {
    return 'Zonder vereenvoudiging (afkoeling langs de buis) is de warmtestroom $exact W; de vereenvoudiging wijkt daar $difference W ($percent %) van af.';
  }

  @override
  String get simplificationInvalid =>
      'De vereenvoudiging is hier niet geldig: het medium zou voorbij de omgevingstemperatuur gaan. Gebruik de exacte berekening.';

  @override
  String get navOverview => 'Overzicht';

  @override
  String get overviewSubtitle =>
      'Technische rekentools. Kies er een om te beginnen.';

  @override
  String get moduleHeatTransfer => 'Warmtetransport';

  @override
  String get moduleHeatTransferDescription =>
      'Warmteverlies en uitlaattemperatuur van een geïsoleerde buis, via convectie, conductie en straling.';

  @override
  String get modulePrice => 'Prijsberekening';

  @override
  String get modulePriceTitle => 'Kosten van energieverlies';

  @override
  String get modulePriceDescription =>
      'Kosten van een warmteverlies over een gebruiksperiode bij een gegeven energiemarktprijs.';

  @override
  String get calculation => 'Berekening';

  @override
  String get priceFieldPower => 'Warmteverlies';

  @override
  String get priceFieldDuration => 'Gebruiksduur';

  @override
  String get priceFieldMarketPrice => 'Marktprijs';

  @override
  String priceUseHeatLoss(String power, String length) {
    return 'Warmteverlies uit Warmtetransport gebruiken: $power W over $length m';
  }

  @override
  String priceFromHeatTransfer(String length) {
    return 'Warmteverlies van $length m buis, overgenomen uit Warmtetransport';
  }

  @override
  String get presetDay => 'Dag';

  @override
  String get presetWeek => 'Week';

  @override
  String get presetMonth => 'Maand';

  @override
  String get presetYear => 'Jaar';

  @override
  String get statCost => 'Kosten';

  @override
  String get statEnergy => 'Energieverlies';

  @override
  String get statCostPerHour => 'Kosten per uur';

  @override
  String get statCostPerMetre => 'Kosten per meter';

  @override
  String get lawEnergyCost => 'Energie en kosten';

  @override
  String get priceStepEnergy => 'Energieverlies over de gebruiksduur';

  @override
  String get priceStepConvert => 'Omgerekend naar MWh (1 MWh = 1 000 000 Wh)';

  @override
  String get priceStepCost => 'Kosten bij de marktprijs';

  @override
  String get priceStepCostPerHour => 'Kosten per gebruiksuur';

  @override
  String get priceStepCostPerMetre => 'Kosten per meter buis';

  @override
  String get symbolPower => 'Warmteverlies (vermogen)';

  @override
  String get symbolDuration => 'Gebruiksduur';

  @override
  String get symbolMarketPrice => 'Energiemarktprijs';

  @override
  String get symbolEnergy => 'Verloren energie';

  @override
  String get symbolCost => 'Kosten van de verloren energie';

  @override
  String get sourceCode => 'Broncode op GitHub';

  @override
  String get about => 'Over';

  @override
  String get aboutText =>
      'SEM tools zijn rekentools voor de banaba Sustainable Energy Management van Howest. Open source onder de MIT-licentie.';

  @override
  String get disclaimer =>
      'Aangeboden zoals ze zijn, voor educatief gebruik. Er wordt geen verantwoordelijkheid genomen voor eventuele fouten; controleer resultaten altijd voor je erop vertrouwt.';

  @override
  String get moduleExpansionTitle => 'Expansie';

  @override
  String get moduleExpansionPageTitle => 'Vloeistofuitzetting in een warmtenet';

  @override
  String get moduleExpansionDescription =>
      'Thermische uitzetting van een vloeistof in een warmtenet uit het dichtheidsverschil tussen koude en warme toestand.';

  @override
  String get expansionSectionVolume => 'Systeemvolume';

  @override
  String get expansionSectionDensity => 'Dichtheid vloeistof';

  @override
  String get expansionModeVolume => 'Direct volume';

  @override
  String get expansionModeTube => 'Uit buis (Dᵢ, L)';

  @override
  String get expansionFieldVolume => 'Beginvolume';

  @override
  String get expansionFieldDensityCold => 'Dichtheid koud';

  @override
  String get expansionFieldDensityHot => 'Dichtheid warm';

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
    return 'Buis uit Warmtetransport gebruiken: Dᵢ = $diameter mm, L = $length m';
  }

  @override
  String expansionFromHeatTransfer(String diameter, String length) {
    return 'Buisafmetingen (Dᵢ = $diameter mm, L = $length m) overgenomen uit Warmtetransport';
  }

  @override
  String get statExpansionVolume => 'Expansievolume';

  @override
  String get statInitialVolume => 'Beginvolume';

  @override
  String get statFinalVolume => 'Opgewarmd volume';

  @override
  String get statMass => 'Massa vloeistof';

  @override
  String get vesselColdState => 'Koud (begin)';

  @override
  String get vesselHeatedState => 'Warm (uitgezet)';

  @override
  String get vesselConstantMass => 'm = constant';

  @override
  String get vesselExpansion => 'Expansie';

  @override
  String get expansionInvalidDensity =>
      'De dichtheid in warme toestand ρ₂ is groter dan of gelijk aan de koude dichtheid ρ₁, waardoor de vloeistof niet uitzet.';

  @override
  String get lawConservationOfMass => 'Behoud van massa';

  @override
  String get expansionStepRadius => 'Binnenstraal van de buis';

  @override
  String get expansionStepTubeVolume =>
      'Beginvolume van de vloeistof in de cilindrische buis';

  @override
  String get expansionStepMass =>
      'Massa van de koude vloeistof (blijft constant bij opwarming)';

  @override
  String get expansionStepFinalVolume =>
      'Volume van de warme vloeistof bij de lagere dichtheid';

  @override
  String get expansionStepDeltaV => 'Volumetoename van de vloeistof';

  @override
  String get expansionStepConvertLitres =>
      'Omgerekend naar liter (1 m³ = 1 000 L)';

  @override
  String get symbolInitialVolume => 'Beginvolume van de vloeistof (koud)';

  @override
  String get symbolFinalVolume => 'Eindvolume van de vloeistof (warm)';

  @override
  String get symbolExpansionVolume => 'Volumetoename van de vloeistof';

  @override
  String get symbolDensityCold =>
      'Dichtheid van de vloeistof in koude toestand';

  @override
  String get symbolDensityHot => 'Dichtheid van de vloeistof in warme toestand';

  @override
  String get symbolMass => 'Massa van de vloeistof in het net';
}
