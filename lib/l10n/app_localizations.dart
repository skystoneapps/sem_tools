import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  /// Name of the app; a product name, not translated.
  ///
  /// In en, this message translates to:
  /// **'SEM tools'**
  String get appTitle;

  /// App bar title.
  ///
  /// In en, this message translates to:
  /// **'Heat transport in an insulated tube'**
  String get screenTitle;

  /// No description provided for @resetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get resetTooltip;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTooltip;

  /// No description provided for @tabTubeAndVariables.
  ///
  /// In en, this message translates to:
  /// **'Tube & variables'**
  String get tabTubeAndVariables;

  /// No description provided for @tabDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get tabDetails;

  /// No description provided for @mechanismConvection.
  ///
  /// In en, this message translates to:
  /// **'Convection'**
  String get mechanismConvection;

  /// No description provided for @mechanismConduction.
  ///
  /// In en, this message translates to:
  /// **'Conduction'**
  String get mechanismConduction;

  /// No description provided for @mechanismRadiation.
  ///
  /// In en, this message translates to:
  /// **'Radiation'**
  String get mechanismRadiation;

  /// No description provided for @lawNewton.
  ///
  /// In en, this message translates to:
  /// **'Newton\'s Law of Cooling'**
  String get lawNewton;

  /// No description provided for @lawFourier.
  ///
  /// In en, this message translates to:
  /// **'Fourier\'s Law'**
  String get lawFourier;

  /// No description provided for @lawStefanBoltzmann.
  ///
  /// In en, this message translates to:
  /// **'Stefan–Boltzmann Law'**
  String get lawStefanBoltzmann;

  /// No description provided for @stageInnerConvection.
  ///
  /// In en, this message translates to:
  /// **'Inner convection'**
  String get stageInnerConvection;

  /// No description provided for @stageInnerConvectionPath.
  ///
  /// In en, this message translates to:
  /// **'Fluid → inner pipe wall'**
  String get stageInnerConvectionPath;

  /// No description provided for @stagePipeConduction.
  ///
  /// In en, this message translates to:
  /// **'Pipe wall conduction'**
  String get stagePipeConduction;

  /// No description provided for @stagePipeConductionPath.
  ///
  /// In en, this message translates to:
  /// **'Through the pipe wall'**
  String get stagePipeConductionPath;

  /// No description provided for @stageInsulationConduction.
  ///
  /// In en, this message translates to:
  /// **'Insulation conduction'**
  String get stageInsulationConduction;

  /// No description provided for @stageInsulationConductionPath.
  ///
  /// In en, this message translates to:
  /// **'Through the insulation layer'**
  String get stageInsulationConductionPath;

  /// No description provided for @stageOuterConvection.
  ///
  /// In en, this message translates to:
  /// **'Outer convection'**
  String get stageOuterConvection;

  /// No description provided for @stageOuterConvectionPath.
  ///
  /// In en, this message translates to:
  /// **'Outer surface → ambient air'**
  String get stageOuterConvectionPath;

  /// No description provided for @stageOuterRadiation.
  ///
  /// In en, this message translates to:
  /// **'Surface radiation'**
  String get stageOuterRadiation;

  /// No description provided for @stageOuterRadiationPath.
  ///
  /// In en, this message translates to:
  /// **'Outer surface → surroundings'**
  String get stageOuterRadiationPath;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @totalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How the stages combine'**
  String get totalSubtitle;

  /// No description provided for @totalPath.
  ///
  /// In en, this message translates to:
  /// **'Fluid → surroundings'**
  String get totalPath;

  /// No description provided for @statHeatFlow.
  ///
  /// In en, this message translates to:
  /// **'Heat flow'**
  String get statHeatFlow;

  /// No description provided for @statResistance.
  ///
  /// In en, this message translates to:
  /// **'Resistance'**
  String get statResistance;

  /// No description provided for @statTemperatureDrop.
  ///
  /// In en, this message translates to:
  /// **'Temperature drop'**
  String get statTemperatureDrop;

  /// No description provided for @statTotalResistance.
  ///
  /// In en, this message translates to:
  /// **'Total resistance'**
  String get statTotalResistance;

  /// No description provided for @stepParallel.
  ///
  /// In en, this message translates to:
  /// **'Convection and radiation act in parallel at the surface'**
  String get stepParallel;

  /// No description provided for @stepSeries.
  ///
  /// In en, this message translates to:
  /// **'The other stages are in series with it'**
  String get stepSeries;

  /// No description provided for @stepTotalHeatFlow.
  ///
  /// In en, this message translates to:
  /// **'Total heat flow'**
  String get stepTotalHeatFlow;

  /// No description provided for @stepHeatFlowPerMetre.
  ///
  /// In en, this message translates to:
  /// **'Heat flow per metre of tube'**
  String get stepHeatFlowPerMetre;

  /// No description provided for @stepInnerArea.
  ///
  /// In en, this message translates to:
  /// **'Area of the inner pipe wall'**
  String get stepInnerArea;

  /// No description provided for @stepThermalResistance.
  ///
  /// In en, this message translates to:
  /// **'Thermal resistance'**
  String get stepThermalResistance;

  /// No description provided for @stepInnerHeatFlow.
  ///
  /// In en, this message translates to:
  /// **'Heat flow from the fluid into the wall'**
  String get stepInnerHeatFlow;

  /// No description provided for @stepInnerWallTemperature.
  ///
  /// In en, this message translates to:
  /// **'Inner wall temperature'**
  String get stepInnerWallTemperature;

  /// No description provided for @stepIntegratedWall.
  ///
  /// In en, this message translates to:
  /// **'Integrated over the cylindrical wall, with A(r) = 2πrL'**
  String get stepIntegratedWall;

  /// No description provided for @stepWallHeatFlow.
  ///
  /// In en, this message translates to:
  /// **'Heat flow through the wall'**
  String get stepWallHeatFlow;

  /// No description provided for @stepOuterPipeTemperature.
  ///
  /// In en, this message translates to:
  /// **'Outer pipe temperature'**
  String get stepOuterPipeTemperature;

  /// No description provided for @stepIntegratedLayer.
  ///
  /// In en, this message translates to:
  /// **'Integrated over the cylindrical layer, with A(r) = 2πrL'**
  String get stepIntegratedLayer;

  /// No description provided for @stepInsulationHeatFlow.
  ///
  /// In en, this message translates to:
  /// **'Heat flow through the insulation'**
  String get stepInsulationHeatFlow;

  /// No description provided for @stepSurfaceTemperature.
  ///
  /// In en, this message translates to:
  /// **'Outer surface temperature'**
  String get stepSurfaceTemperature;

  /// No description provided for @stepOuterArea.
  ///
  /// In en, this message translates to:
  /// **'Area of the outer surface'**
  String get stepOuterArea;

  /// No description provided for @stepConvectionHeatFlow.
  ///
  /// In en, this message translates to:
  /// **'Heat carried away by the air'**
  String get stepConvectionHeatFlow;

  /// No description provided for @stepAbsoluteTemperatures.
  ///
  /// In en, this message translates to:
  /// **'Radiation needs absolute temperatures'**
  String get stepAbsoluteTemperatures;

  /// No description provided for @stepRadiatedHeat.
  ///
  /// In en, this message translates to:
  /// **'Heat radiated to the surroundings'**
  String get stepRadiatedHeat;

  /// No description provided for @stepLinearisedCoefficient.
  ///
  /// In en, this message translates to:
  /// **'Linearised radiation coefficient'**
  String get stepLinearisedCoefficient;

  /// No description provided for @stepEquivalentResistance.
  ///
  /// In en, this message translates to:
  /// **'Equivalent thermal resistance'**
  String get stepEquivalentResistance;

  /// T_s is formula markup: the underscore makes 's' a subscript. Keep it as is.
  ///
  /// In en, this message translates to:
  /// **'T_s is not known in advance: it is solved iteratively so that the heat arriving at the surface equals the heat leaving it by convection and radiation together.'**
  String get surfaceIterationNote;

  /// No description provided for @variables.
  ///
  /// In en, this message translates to:
  /// **'Variables'**
  String get variables;

  /// No description provided for @sectionTemperatures.
  ///
  /// In en, this message translates to:
  /// **'Temperatures'**
  String get sectionTemperatures;

  /// No description provided for @sectionGeometry.
  ///
  /// In en, this message translates to:
  /// **'Geometry'**
  String get sectionGeometry;

  /// No description provided for @sectionMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get sectionMaterials;

  /// No description provided for @sectionSurfaces.
  ///
  /// In en, this message translates to:
  /// **'Surfaces'**
  String get sectionSurfaces;

  /// No description provided for @fieldAmbientTemperature.
  ///
  /// In en, this message translates to:
  /// **'Ambient'**
  String get fieldAmbientTemperature;

  /// No description provided for @fieldLength.
  ///
  /// In en, this message translates to:
  /// **'Tube length'**
  String get fieldLength;

  /// No description provided for @fieldInnerDiameter.
  ///
  /// In en, this message translates to:
  /// **'Inner diameter'**
  String get fieldInnerDiameter;

  /// No description provided for @fieldWallThickness.
  ///
  /// In en, this message translates to:
  /// **'Wall thickness'**
  String get fieldWallThickness;

  /// No description provided for @fieldInsulationThickness.
  ///
  /// In en, this message translates to:
  /// **'Insulation'**
  String get fieldInsulationThickness;

  /// No description provided for @fieldPipeConductivity.
  ///
  /// In en, this message translates to:
  /// **'Pipe conductivity'**
  String get fieldPipeConductivity;

  /// No description provided for @fieldInsulationConductivity.
  ///
  /// In en, this message translates to:
  /// **'Insulation conductivity'**
  String get fieldInsulationConductivity;

  /// No description provided for @fieldInnerConvection.
  ///
  /// In en, this message translates to:
  /// **'Inner convection'**
  String get fieldInnerConvection;

  /// No description provided for @fieldOuterConvection.
  ///
  /// In en, this message translates to:
  /// **'Outer convection'**
  String get fieldOuterConvection;

  /// No description provided for @fieldEmissivity.
  ///
  /// In en, this message translates to:
  /// **'Surface emissivity'**
  String get fieldEmissivity;

  /// No description provided for @presetsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get presetsTooltip;

  /// No description provided for @errorEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get errorEnterNumber;

  /// No description provided for @presetCarbonSteel.
  ///
  /// In en, this message translates to:
  /// **'Carbon steel'**
  String get presetCarbonSteel;

  /// No description provided for @presetStainlessSteel.
  ///
  /// In en, this message translates to:
  /// **'Stainless steel'**
  String get presetStainlessSteel;

  /// No description provided for @presetCopper.
  ///
  /// In en, this message translates to:
  /// **'Copper'**
  String get presetCopper;

  /// No description provided for @presetAluminium.
  ///
  /// In en, this message translates to:
  /// **'Aluminium'**
  String get presetAluminium;

  /// No description provided for @presetPvc.
  ///
  /// In en, this message translates to:
  /// **'PVC'**
  String get presetPvc;

  /// No description provided for @presetMineralWool.
  ///
  /// In en, this message translates to:
  /// **'Mineral wool'**
  String get presetMineralWool;

  /// No description provided for @presetPolyurethaneFoam.
  ///
  /// In en, this message translates to:
  /// **'Polyurethane foam'**
  String get presetPolyurethaneFoam;

  /// No description provided for @presetElastomericFoam.
  ///
  /// In en, this message translates to:
  /// **'Elastomeric foam'**
  String get presetElastomericFoam;

  /// No description provided for @presetCalciumSilicate.
  ///
  /// In en, this message translates to:
  /// **'Calcium silicate'**
  String get presetCalciumSilicate;

  /// No description provided for @presetAerogelBlanket.
  ///
  /// In en, this message translates to:
  /// **'Aerogel blanket'**
  String get presetAerogelBlanket;

  /// No description provided for @presetGasForced.
  ///
  /// In en, this message translates to:
  /// **'Gas, forced flow'**
  String get presetGasForced;

  /// No description provided for @presetOilForced.
  ///
  /// In en, this message translates to:
  /// **'Oil, forced flow'**
  String get presetOilForced;

  /// No description provided for @presetWaterForced.
  ///
  /// In en, this message translates to:
  /// **'Water, forced flow'**
  String get presetWaterForced;

  /// No description provided for @presetWaterTurbulent.
  ///
  /// In en, this message translates to:
  /// **'Water, turbulent'**
  String get presetWaterTurbulent;

  /// No description provided for @presetCondensingSteam.
  ///
  /// In en, this message translates to:
  /// **'Condensing steam'**
  String get presetCondensingSteam;

  /// No description provided for @presetStillAir.
  ///
  /// In en, this message translates to:
  /// **'Still air'**
  String get presetStillAir;

  /// No description provided for @presetIndoorAir.
  ///
  /// In en, this message translates to:
  /// **'Indoor air'**
  String get presetIndoorAir;

  /// No description provided for @presetLightWind.
  ///
  /// In en, this message translates to:
  /// **'Light wind'**
  String get presetLightWind;

  /// No description provided for @presetStrongWind.
  ///
  /// In en, this message translates to:
  /// **'Strong wind'**
  String get presetStrongWind;

  /// No description provided for @presetPolishedAluminium.
  ///
  /// In en, this message translates to:
  /// **'Polished aluminium'**
  String get presetPolishedAluminium;

  /// No description provided for @presetOxidisedAluminium.
  ///
  /// In en, this message translates to:
  /// **'Oxidised aluminium'**
  String get presetOxidisedAluminium;

  /// No description provided for @presetStainlessJacket.
  ///
  /// In en, this message translates to:
  /// **'Stainless steel jacket'**
  String get presetStainlessJacket;

  /// No description provided for @presetPvcJacket.
  ///
  /// In en, this message translates to:
  /// **'PVC jacket'**
  String get presetPvcJacket;

  /// No description provided for @presetPaintedSurface.
  ///
  /// In en, this message translates to:
  /// **'Painted surface'**
  String get presetPaintedSurface;

  /// Label in the tube drawing, followed by the ambient temperature.
  ///
  /// In en, this message translates to:
  /// **'Ambient'**
  String get tubeAmbient;

  /// Small label above the surface temperature in the tube drawing.
  ///
  /// In en, this message translates to:
  /// **'outer surface'**
  String get tubeOuterSurface;

  /// No description provided for @tubePipeWall.
  ///
  /// In en, this message translates to:
  /// **'Pipe wall'**
  String get tubePipeWall;

  /// No description provided for @tubeInsulation.
  ///
  /// In en, this message translates to:
  /// **'Insulation'**
  String get tubeInsulation;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// Column header of the results table.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get resultsStage;

  /// No description provided for @inParallel.
  ///
  /// In en, this message translates to:
  /// **'in parallel'**
  String get inParallel;

  /// No description provided for @errorGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'Must be > {value}'**
  String errorGreaterThan(String value);

  /// No description provided for @errorAtLeast.
  ///
  /// In en, this message translates to:
  /// **'Must be ≥ {value}'**
  String errorAtLeast(String value);

  /// No description provided for @errorAtMost.
  ///
  /// In en, this message translates to:
  /// **'Must be ≤ {value}'**
  String errorAtMost(String value);

  /// No description provided for @resultsTubeLength.
  ///
  /// In en, this message translates to:
  /// **'over {length} m of tube'**
  String resultsTubeLength(String length);

  /// Tooltip for the symbol Q in formulas. The symbol* keys are all hover descriptions of formula symbols.
  ///
  /// In en, this message translates to:
  /// **'Heat flow'**
  String get symbolHeatFlow;

  /// No description provided for @symbolHeatFlowConvection.
  ///
  /// In en, this message translates to:
  /// **'Heat carried away by outer convection'**
  String get symbolHeatFlowConvection;

  /// No description provided for @symbolHeatFlowRadiation.
  ///
  /// In en, this message translates to:
  /// **'Heat radiated by the outer surface'**
  String get symbolHeatFlowRadiation;

  /// No description provided for @symbolHeatFlowPerMetre.
  ///
  /// In en, this message translates to:
  /// **'Heat flow per metre of tube'**
  String get symbolHeatFlowPerMetre;

  /// No description provided for @symbolAreaInner.
  ///
  /// In en, this message translates to:
  /// **'Inner surface area of the pipe'**
  String get symbolAreaInner;

  /// No description provided for @symbolAreaOuter.
  ///
  /// In en, this message translates to:
  /// **'Outer surface area of the insulation'**
  String get symbolAreaOuter;

  /// No description provided for @symbolConvectionCoefficientInner.
  ///
  /// In en, this message translates to:
  /// **'Convection coefficient on the fluid side'**
  String get symbolConvectionCoefficientInner;

  /// No description provided for @symbolConvectionCoefficientOuter.
  ///
  /// In en, this message translates to:
  /// **'Convection coefficient on the air side'**
  String get symbolConvectionCoefficientOuter;

  /// No description provided for @symbolRadiationCoefficient.
  ///
  /// In en, this message translates to:
  /// **'Linearised radiation coefficient'**
  String get symbolRadiationCoefficient;

  /// No description provided for @symbolConductivityPipe.
  ///
  /// In en, this message translates to:
  /// **'Thermal conductivity of the pipe wall'**
  String get symbolConductivityPipe;

  /// No description provided for @symbolConductivityInsulation.
  ///
  /// In en, this message translates to:
  /// **'Thermal conductivity of the insulation'**
  String get symbolConductivityInsulation;

  /// No description provided for @symbolAmbientTemperature.
  ///
  /// In en, this message translates to:
  /// **'Ambient temperature'**
  String get symbolAmbientTemperature;

  /// No description provided for @symbolSurfaceTemperature.
  ///
  /// In en, this message translates to:
  /// **'Outer surface temperature'**
  String get symbolSurfaceTemperature;

  /// No description provided for @symbolInnerWallTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature of the inner pipe wall'**
  String get symbolInnerWallTemperature;

  /// No description provided for @symbolInterfaceTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature between pipe and insulation'**
  String get symbolInterfaceTemperature;

  /// No description provided for @symbolTemperatureDifference.
  ///
  /// In en, this message translates to:
  /// **'Temperature difference across the stage'**
  String get symbolTemperatureDifference;

  /// No description provided for @symbolTemperatureGradient.
  ///
  /// In en, this message translates to:
  /// **'Temperature gradient in the radial direction'**
  String get symbolTemperatureGradient;

  /// No description provided for @symbolRadius.
  ///
  /// In en, this message translates to:
  /// **'Radius'**
  String get symbolRadius;

  /// No description provided for @symbolRadiusInner.
  ///
  /// In en, this message translates to:
  /// **'Inner radius of the pipe'**
  String get symbolRadiusInner;

  /// No description provided for @symbolRadiusPipe.
  ///
  /// In en, this message translates to:
  /// **'Outer radius of the pipe'**
  String get symbolRadiusPipe;

  /// No description provided for @symbolRadiusOuter.
  ///
  /// In en, this message translates to:
  /// **'Outer radius of the insulation'**
  String get symbolRadiusOuter;

  /// No description provided for @symbolLength.
  ///
  /// In en, this message translates to:
  /// **'Tube length'**
  String get symbolLength;

  /// No description provided for @symbolResistance.
  ///
  /// In en, this message translates to:
  /// **'Thermal resistance'**
  String get symbolResistance;

  /// No description provided for @symbolResistanceInnerConvection.
  ///
  /// In en, this message translates to:
  /// **'Thermal resistance of inner convection'**
  String get symbolResistanceInnerConvection;

  /// No description provided for @symbolResistancePipe.
  ///
  /// In en, this message translates to:
  /// **'Thermal resistance of the pipe wall'**
  String get symbolResistancePipe;

  /// No description provided for @symbolResistanceInsulation.
  ///
  /// In en, this message translates to:
  /// **'Thermal resistance of the insulation'**
  String get symbolResistanceInsulation;

  /// No description provided for @symbolResistanceOuterConvection.
  ///
  /// In en, this message translates to:
  /// **'Thermal resistance of outer convection'**
  String get symbolResistanceOuterConvection;

  /// No description provided for @symbolResistanceRadiation.
  ///
  /// In en, this message translates to:
  /// **'Thermal resistance of surface radiation'**
  String get symbolResistanceRadiation;

  /// No description provided for @symbolResistanceOuter.
  ///
  /// In en, this message translates to:
  /// **'Combined resistance at the outer surface: convection and radiation in parallel'**
  String get symbolResistanceOuter;

  /// No description provided for @symbolResistanceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total thermal resistance from fluid to surroundings'**
  String get symbolResistanceTotal;

  /// No description provided for @symbolEmissivity.
  ///
  /// In en, this message translates to:
  /// **'Emissivity of the outer surface, from 0 (mirror) to 1 (black body)'**
  String get symbolEmissivity;

  /// No description provided for @symbolStefanBoltzmann.
  ///
  /// In en, this message translates to:
  /// **'Stefan–Boltzmann constant'**
  String get symbolStefanBoltzmann;

  /// No description provided for @fieldInletTemperature.
  ///
  /// In en, this message translates to:
  /// **'Fluid inlet'**
  String get fieldInletTemperature;

  /// No description provided for @sectionFlow.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get sectionFlow;

  /// No description provided for @fieldMassFlow.
  ///
  /// In en, this message translates to:
  /// **'Mass flow rate'**
  String get fieldMassFlow;

  /// No description provided for @fieldSpecificHeat.
  ///
  /// In en, this message translates to:
  /// **'Specific heat'**
  String get fieldSpecificHeat;

  /// No description provided for @presetWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get presetWater;

  /// No description provided for @presetThermalOil.
  ///
  /// In en, this message translates to:
  /// **'Thermal oil'**
  String get presetThermalOil;

  /// No description provided for @presetGlycol.
  ///
  /// In en, this message translates to:
  /// **'Water/glycol 50 %'**
  String get presetGlycol;

  /// No description provided for @presetAir.
  ///
  /// In en, this message translates to:
  /// **'Air'**
  String get presetAir;

  /// No description provided for @presetSteam.
  ///
  /// In en, this message translates to:
  /// **'Superheated steam'**
  String get presetSteam;

  /// No description provided for @tubeInlet.
  ///
  /// In en, this message translates to:
  /// **'Inlet'**
  String get tubeInlet;

  /// No description provided for @tubeOutlet.
  ///
  /// In en, this message translates to:
  /// **'Outlet'**
  String get tubeOutlet;

  /// No description provided for @where.
  ///
  /// In en, this message translates to:
  /// **'where'**
  String get where;

  /// No description provided for @lawEnergyBalance.
  ///
  /// In en, this message translates to:
  /// **'Energy balance on the fluid'**
  String get lawEnergyBalance;

  /// No description provided for @stepOutletTemperature.
  ///
  /// In en, this message translates to:
  /// **'Along the tube, the fluid temperature approaches ambient exponentially'**
  String get stepOutletTemperature;

  /// No description provided for @stepMeanTemperature.
  ///
  /// In en, this message translates to:
  /// **'Logarithmic mean fluid temperature, used for every stage'**
  String get stepMeanTemperature;

  /// No description provided for @stepCheck.
  ///
  /// In en, this message translates to:
  /// **'Check: the same heat flow through the thermal resistances'**
  String get stepCheck;

  /// No description provided for @statInletTemperature.
  ///
  /// In en, this message translates to:
  /// **'Inlet temperature'**
  String get statInletTemperature;

  /// No description provided for @statOutletTemperature.
  ///
  /// In en, this message translates to:
  /// **'Outlet temperature'**
  String get statOutletTemperature;

  /// No description provided for @statFluidChange.
  ///
  /// In en, this message translates to:
  /// **'Change along the tube'**
  String get statFluidChange;

  /// No description provided for @symbolInletTemperature.
  ///
  /// In en, this message translates to:
  /// **'Fluid temperature at the inlet'**
  String get symbolInletTemperature;

  /// No description provided for @symbolOutletTemperature.
  ///
  /// In en, this message translates to:
  /// **'Fluid temperature at the outlet (end of the tube)'**
  String get symbolOutletTemperature;

  /// No description provided for @symbolMeanFluidTemperature.
  ///
  /// In en, this message translates to:
  /// **'Logarithmic mean fluid temperature'**
  String get symbolMeanFluidTemperature;

  /// No description provided for @symbolMassFlow.
  ///
  /// In en, this message translates to:
  /// **'Mass flow rate of the fluid'**
  String get symbolMassFlow;

  /// No description provided for @symbolSpecificHeat.
  ///
  /// In en, this message translates to:
  /// **'Specific heat capacity of the fluid'**
  String get symbolSpecificHeat;

  /// No description provided for @ignoreRadiation.
  ///
  /// In en, this message translates to:
  /// **'Ignore radiation'**
  String get ignoreRadiation;

  /// No description provided for @includeRadiation.
  ///
  /// In en, this message translates to:
  /// **'Include radiation'**
  String get includeRadiation;

  /// No description provided for @radiationIgnored.
  ///
  /// In en, this message translates to:
  /// **'Radiation is ignored in the calculation.'**
  String get radiationIgnored;

  /// No description provided for @stepOnlyConvection.
  ///
  /// In en, this message translates to:
  /// **'Radiation is ignored, so only convection acts at the surface'**
  String get stepOnlyConvection;

  /// No description provided for @simplifyConstantTemperature.
  ///
  /// In en, this message translates to:
  /// **'Constant fluid temperature (simplified)'**
  String get simplifyConstantTemperature;

  /// No description provided for @simplifyConstantTemperatureHint.
  ///
  /// In en, this message translates to:
  /// **'Ignore the cooling along the tube: every metre loses heat as if the fluid were at its inlet temperature.'**
  String get simplifyConstantTemperatureHint;

  /// No description provided for @simplifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Simplified'**
  String get simplifiedBadge;

  /// No description provided for @lawSeries.
  ///
  /// In en, this message translates to:
  /// **'Thermal resistances in series'**
  String get lawSeries;

  /// No description provided for @stepConstantFluid.
  ///
  /// In en, this message translates to:
  /// **'Simplified: the fluid stays at its inlet temperature along the whole tube'**
  String get stepConstantFluid;

  /// No description provided for @stepOutletEnergyBalance.
  ///
  /// In en, this message translates to:
  /// **'Outlet temperature from the energy balance on the fluid'**
  String get stepOutletEnergyBalance;

  /// No description provided for @simplificationComparison.
  ///
  /// In en, this message translates to:
  /// **'Without the simplification (fluid cooling along the tube) the heat flow is {exact} W; the simplification differs by {difference} W ({percent} %).'**
  String simplificationComparison(
    String exact,
    String difference,
    String percent,
  );

  /// No description provided for @simplificationInvalid.
  ///
  /// In en, this message translates to:
  /// **'The simplification is not valid here: the fluid would pass the ambient temperature. Use the exact calculation.'**
  String get simplificationInvalid;

  /// No description provided for @navOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get navOverview;

  /// No description provided for @overviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Engineering calculation tools. Pick one to get started.'**
  String get overviewSubtitle;

  /// Short module name in the navigation rail or drawer.
  ///
  /// In en, this message translates to:
  /// **'Heat transport'**
  String get moduleHeatTransfer;

  /// No description provided for @moduleHeatTransferDescription.
  ///
  /// In en, this message translates to:
  /// **'Heat loss and outlet temperature of an insulated tube, through convection, conduction and radiation.'**
  String get moduleHeatTransferDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
