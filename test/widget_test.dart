import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:sem/heat_transfer/ui/details_pane.dart';
import 'package:sem/common/ui/number_format.dart';
import 'package:sem/expansion/domain/expansion_model.dart';
import 'package:sem/expansion/ui/expansion_controller.dart';
import 'package:sem/heat_transfer/domain/heat_transfer.dart';
import 'package:sem/heat_transfer/ui/inputs_panel.dart';
import 'package:sem/main.dart';
import 'package:sem/price/domain/price_model.dart';
import 'package:sem/price/ui/price_controller.dart';
import 'package:sem/steam/domain/steam_model.dart';
import 'package:sem/steam/ui/enthalpy_diagram_painter.dart';

/// Opens the heat transport module from the navigation rail.
Future<void> openHeatTransfer(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationRail),
      matching: find.text('Heat transport'),
    ),
  );
  await tester.pump();
}

void main() {
  group('calculateHeatTransfer', () {
    const inputs = TubeInputs();

    test('without radiation it matches a hand calculation', () {
      final result = calculateHeatTransfer(inputs.copyWith(emissivity: 0));
      final l = inputs.length;
      final rTotal =
          1 / (inputs.hInner * 2 * math.pi * inputs.r1 * l) +
          math.log(inputs.r2 / inputs.r1) / (2 * math.pi * inputs.kPipe * l) +
          math.log(inputs.r3 / inputs.r2) /
              (2 * math.pi * inputs.kInsulation * l) +
          1 / (inputs.hOuter * 2 * math.pi * inputs.r3 * l);
      final tInf = inputs.ambientTemp;
      final tOut =
          tInf +
          (inputs.inletTemp - tInf) *
              math.exp(-1 / (rTotal * inputs.massFlow * inputs.specificHeat));
      final expected =
          inputs.massFlow * inputs.specificHeat * (inputs.inletTemp - tOut);
      expect(result.totalResistance, closeTo(rTotal, 1e-9));
      expect(result.outletTemp, closeTo(tOut, 1e-9));
      expect(result.heatRate, closeTo(expected, 1e-6));
      expect(result[HeatStage.outerRadiation].heatRate, 0);
    });

    test('energy balances hold at the surface and along the tube', () {
      final result = calculateHeatTransfer(inputs);
      final conv = result[HeatStage.outerConvection];
      final rad = result[HeatStage.outerRadiation];
      final ins = result[HeatStage.insulationConduction];
      expect(conv.heatRate + rad.heatRate, closeTo(result.heatRate, 1e-6));
      expect(ins.deltaT / ins.resistance, closeTo(result.heatRate, 1e-6));
      // What the fluid loses is what leaves through the wall.
      expect(
        inputs.massFlow *
            inputs.specificHeat *
            (result.inletTemp - result.outletTemp),
        closeTo(result.heatRate, 1e-6),
      );
      expect(result.outletTemp, inExclusiveRange(20, inputs.inletTemp));
      expect(
        result.meanFluidTemp,
        inExclusiveRange(result.outletTemp, inputs.inletTemp),
      );
      expect(result.surfaceTemp, inExclusiveRange(20, result.meanFluidTemp));
    });

    test('ignoring radiation is the same as a non-radiating surface', () {
      final ignored = calculateHeatTransfer(
        inputs.copyWith(includeRadiation: false),
      );
      final black = calculateHeatTransfer(inputs.copyWith(emissivity: 0));
      expect(ignored.heatRate, closeTo(black.heatRate, 1e-9));
      expect(ignored[HeatStage.outerRadiation].heatRate, 0);
      expect(
        ignored.heatRate,
        lessThan(calculateHeatTransfer(inputs).heatRate),
      );
    });

    test('the simplification keeps the fluid at its inlet temperature', () {
      final simplified = calculateHeatTransfer(
        inputs.copyWith(constantFluidTemp: true),
      );
      final exact = calculateHeatTransfer(inputs);
      expect(
        simplified.heatRate,
        closeTo(
          (inputs.inletTemp - inputs.ambientTemp) / simplified.totalResistance,
          1e-6,
        ),
      );
      expect(
        simplified.outletTemp,
        closeTo(
          inputs.inletTemp - simplified.heatRate / inputs.capacityRate,
          1e-9,
        ),
      );
      expect(simplified.meanFluidTemp, inputs.inletTemp);
      expect(simplified.exactHeatRate, closeTo(exact.heatRate, 1e-9));
      // Ignoring the cooling along the tube overestimates the loss slightly.
      expect(simplified.heatRate, greaterThan(exact.heatRate));
      expect(simplified.heatRate / exact.heatRate, lessThan(1.01));
      expect(simplified.simplificationValid, isTrue);
    });

    test('the simplification is flagged when the flow is too small', () {
      final result = calculateHeatTransfer(
        inputs.copyWith(constantFluidTemp: true, massFlow: 0.0005),
      );
      expect(result.outletTemp, lessThan(inputs.ambientTemp));
      expect(result.simplificationValid, isFalse);
    });

    test('a very large flow keeps the fluid at its inlet temperature', () {
      final result = calculateHeatTransfer(inputs.copyWith(massFlow: 1e6));
      expect(result.outletTemp, closeTo(inputs.inletTemp, 1e-4));
      expect(
        result.heatRate,
        closeTo(
          (inputs.inletTemp - inputs.ambientTemp) / result.totalResistance,
          1e-3,
        ),
      );
    });

    test('heat flows inward when the fluid is colder than ambient', () {
      final result = calculateHeatTransfer(
        inputs.copyWith(inletTemp: 5, ambientTemp: 25),
      );
      expect(result.heatRate, lessThan(0));
      expect(result.outletTemp, inExclusiveRange(5, 25));
      expect(result.surfaceTemp, inInclusiveRange(5, 25));
    });

    test('no heat leaves without outer convection or radiation', () {
      final result = calculateHeatTransfer(
        inputs.copyWith(hOuter: 0, emissivity: 0),
      );
      expect(result.heatRate, closeTo(0, 1e-9));
      expect(result.outletTemp, closeTo(inputs.inletTemp, 1e-9));
      expect(result.surfaceTemp, closeTo(inputs.inletTemp, 1e-6));
    });
  });

  testWidgets('result rows and the picker select the detailed stage', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SemToolsApp());
    await openHeatTransfer(tester);
    expect(find.text('Heat transport in an insulated tube'), findsOneWidget);
    // Inner convection is selected initially.
    expect(find.text('Inner wall temperature'), findsOneWidget);

    final left = find
        .descendant(
          of: find.ancestor(
            of: find.byType(InputsPanel),
            matching: find.byType(ListView),
          ),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Surface radiation'),
      300,
      scrollable: left,
    );
    await tester.drag(left, const Offset(0, -300));
    await tester.pump();
    await tester.tap(find.text('Surface radiation'));
    await tester.pump();
    expect(find.text('Linearised radiation coefficient'), findsOneWidget);
    expect(find.text('Inner wall temperature'), findsNothing);

    // Open the picker and choose the total.
    await tester.tap(
      find.descendant(
        of: find.byType(DetailsPane),
        matching: find.byIcon(Icons.arrow_drop_down),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(MenuItemButton, 'Total'));
    // Menu items fire after the frame in which the menu closes.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text('Total heat flow'), findsOneWidget);
    expect(find.text('Linearised radiation coefficient'), findsNothing);
  });

  testWidgets('the language picker switches to Dutch with decimal commas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(() => Intl.defaultLocale = null);

    await tester.pumpWidget(const SemToolsApp(initialLocale: Locale('en')));
    await openHeatTransfer(tester);
    expect(find.text('Heat transport in an insulated tube'), findsOneWidget);
    expect(find.text('0.04'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.translate));
    // Let the menu finish opening before tapping an item.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(
      find.widgetWithText(CheckedPopupMenuItem<Locale>, 'Nederlands'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.text('Warmtetransport in een geïsoleerde buis'),
      findsOneWidget,
    );
    expect(find.text('Variabelen'), findsOneWidget);
    // Valid entries are rewritten with the Dutch decimal separator.
    expect(find.text('0,04'), findsOneWidget);
    expect(find.text('Inwendige convectie'), findsWidgets);
  });

  testWidgets('symbols are explained in the derivation and on hover', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SemToolsApp(initialLocale: Locale('en')));
    await openHeatTransfer(tester);
    // The "where:" list under the inner convection derivation.
    expect(find.text('where'), findsOneWidget);
    expect(
      find.textContaining('Inner surface area of the pipe', findRichText: true),
      findsOneWidget,
    );

    // Symbols in the results table header explain themselves on hover.
    final left = find
        .descendant(
          of: find.ancestor(
            of: find.byType(InputsPanel),
            matching: find.byType(ListView),
          ),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(find.text('Stage'), 300, scrollable: left);
    await tester.drag(left, const Offset(0, -200));
    await tester.pump();
    const message = 'Temperature difference across the stage  [K]';
    final symbol = find.byTooltip(message);
    expect(symbol, findsOneWidget);
    // Units such as "K" are not treated as symbols.
    expect(find.byTooltip('K'), findsNothing);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(symbol));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text(message), findsOneWidget);
  });

  testWidgets('the eye button ignores and includes radiation', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SemToolsApp(initialLocale: Locale('en')));
    await openHeatTransfer(tester);
    final left = find
        .descendant(
          of: find.ancestor(
            of: find.byType(InputsPanel),
            matching: find.byType(ListView),
          ),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.byTooltip('Ignore radiation'),
      300,
      scrollable: left,
    );
    await tester.drag(left, const Offset(0, -200));
    await tester.pump();

    final withRadiation = calculateHeatTransfer(const TubeInputs());
    final without = calculateHeatTransfer(
      const TubeInputs(includeRadiation: false),
    );
    // Heat flows in the results table.
    expect(find.text(fmtValue(withRadiation.heatRate)), findsWidgets);

    await tester.tap(find.byTooltip('Ignore radiation'));
    await tester.pump();
    expect(find.text(fmtValue(withRadiation.heatRate)), findsNothing);
    expect(find.text(fmtValue(without.heatRate)), findsWidgets);
    expect(find.byTooltip('Include radiation'), findsOneWidget);

    // The detail pane explains that radiation is ignored.
    await tester.tap(find.text('Surface radiation'));
    await tester.pump();
    expect(
      find.text('Radiation is ignored in the calculation.'),
      findsOneWidget,
    );
  });

  testWidgets('the simplification checkbox switches the calculation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SemToolsApp(initialLocale: Locale('en')));
    await openHeatTransfer(tester);
    expect(find.text('Simplified'), findsNothing);

    await tester.tap(find.text('Constant fluid temperature (simplified)'));
    await tester.pump();
    // The results are marked as simplified.
    final left = find
        .descendant(
          of: find.ancestor(
            of: find.byType(InputsPanel),
            matching: find.byType(ListView),
          ),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Simplified'),
      300,
      scrollable: left,
    );
    expect(find.text('Simplified'), findsOneWidget);

    final simplified = calculateHeatTransfer(
      const TubeInputs(constantFluidTemp: true),
    );
    // The Total explains the simplified calculation and compares it.
    await tester.tap(
      find.descendant(
        of: find.byType(DetailsPane),
        matching: find.byIcon(Icons.arrow_drop_down),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.widgetWithText(MenuItemButton, 'Total'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(find.text('${fmtValue(simplified.heatRate)} W'), findsOneWidget);
    expect(find.textContaining('Without the simplification'), findsOneWidget);
  });

  group('app shell', () {
    testWidgets('starts on the overview and opens modules from it', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const SemToolsApp(initialLocale: Locale('en')));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.text('SEM tools'), findsWidgets);
      // The repository is linked from the overview and the rail.
      expect(
        find.text(
          'Source code on GitHub  ·  github.com/skystoneapps/sem_tools',
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('Source code on GitHub'), findsOneWidget);

      // The module card on the overview opens the module.
      await tester.tap(find.text('Heat transport in an insulated tube'));
      await tester.pump();
      expect(find.text('Inner wall temperature'), findsOneWidget);
      expect(find.byTooltip('Reset to defaults'), findsOneWidget);
    });

    testWidgets('module state survives switching modules', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const SemToolsApp(initialLocale: Locale('en')));
      await openHeatTransfer(tester);
      await tester.enterText(find.widgetWithText(TextField, '150'), '90');
      await tester.pump();

      await tester.tap(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text('Overview'),
        ),
      );
      await tester.pump();
      expect(find.byTooltip('Reset to defaults'), findsNothing);

      await openHeatTransfer(tester);
      expect(find.widgetWithText(TextField, '90'), findsOneWidget);
    });

    testWidgets('narrow screens navigate with a drawer', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const SemToolsApp(initialLocale: Locale('en')));
      expect(find.byType(NavigationRail), findsNothing);

      await tester.tap(find.byTooltip('Open navigation menu'));
      // Let the drawer finish sliding in before tapping a destination.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationDrawer),
          matching: find.text('Heat transport'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      // The module is open (its tabs show) and the drawer has closed.
      expect(find.text('Tube & variables'), findsOneWidget);
      expect(find.byType(NavigationDrawer), findsNothing);
    });
  });

  group('price calculation', () {
    test('energy and cost follow from power, duration and price', () {
      final result = calculatePrice(
        const PriceInputs(power: 1000, duration: 3000, marketPrice: 100),
      );
      expect(result.energyWattHours, 3e6);
      expect(result.energyMegawattHours, 3);
      expect(result.cost, 300);
      expect(result.costPerHour, closeTo(0.1, 1e-12));
    });

    test('a typed heat loss is no longer tied to an imported tube', () {
      final controller = PriceController()..importHeatLoss(3227.85, 75);
      expect(controller.tubeLength, 75);
      controller.inputs = controller.inputs.copyWith(duration: 5000);
      expect(controller.tubeLength, 75);
      controller.inputs = controller.inputs.copyWith(power: 100);
      expect(controller.tubeLength, isNull);
    });

    testWidgets('imports the heat loss and shows the cost', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const SemToolsApp(initialLocale: Locale('en')));
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text('Price calculation'),
        ),
      );
      await tester.pump();
      expect(find.text('Cost of energy loss'), findsOneWidget);
      // Defaults: 1000 W for 3000 h at €100/MWh.
      expect(find.text('€300.00'), findsOneWidget);
      expect(find.text('Cost per metre'), findsNothing);

      final heatLoss = calculateHeatTransfer(const TubeInputs()).heatRate;
      final imported = (heatLoss * 100).roundToDouble() / 100;
      await tester.tap(
        find.textContaining('Use heat loss from Heat transport'),
      );
      await tester.pump();
      expect(
        find.widgetWithText(TextField, fmtInput(imported)),
        findsOneWidget,
      );
      expect(
        find.text(fmtCurrency(imported * 3000 / 1e6 * 100)),
        findsOneWidget,
      );
      expect(find.text('Cost per metre'), findsOneWidget);
    });
  });

  group('expansion calculation', () {
    test('volume expansion follows conservation of mass from densities', () {
      final result = calculateExpansion(const ExpansionInputs());
      // Defaults: V₀ = 1 m³ (1000 L), ρ₁ = 999.7 kg/m³, ρ₂ = 965.3 kg/m³.
      expect(result.initialVolume, 1);
      expect(result.initialLitres, 1000);
      expect(result.mass, closeTo(999.7, 1e-9));
      expect(result.finalVolume, closeTo(999.7 / 965.3, 1e-9));
      expect(result.expansionVolume, closeTo(999.7 / 965.3 - 1, 1e-9));
      expect(result.expansionLitres, closeTo((999.7 / 965.3 - 1) * 1000, 1e-6));
    });

    test('tube geometry mode computes V₀ = π·r₁²·L', () {
      // D_i = 50 mm (r₁ = 0.025 m), L = 100 m -> π * 0.025² * 100 m³.
      final result = calculateExpansion(
        const ExpansionInputs(
          useTubeGeometry: true,
          innerDiameter: 50,
          length: 100,
        ),
      );
      final expectedV0 = math.pi * 0.025 * 0.025 * 100;
      expect(result.initialVolume, closeTo(expectedV0, 1e-12));
      expect(result.initialLitres, closeTo(expectedV0 * 1000, 1e-9));
    });

    test('editing tube dimensions detaches from Heat transport import', () {
      final controller = ExpansionController()
        ..importTube(innerDiameterMm: 50, lengthM: 10);
      expect(controller.fromHeatTransfer, isTrue);
      controller.inputs = controller.inputs.copyWith(densityHot: 950);
      expect(controller.fromHeatTransfer, isTrue);
      controller.inputs = controller.inputs.copyWith(length: 25);
      expect(controller.fromHeatTransfer, isFalse);
    });

    testWidgets('switches between direct volume and tube geometry', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const SemToolsApp(initialLocale: Locale('en')));
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text('Expansion'),
        ),
      );
      await tester.pump();
      expect(find.text('Liquid expansion in a heat network'), findsOneWidget);
      expect(find.text('Conservation of mass'), findsOneWidget);
      expect(find.text('35.64 L'), findsOneWidget);
      expect(find.text('999.70 kg'), findsOneWidget);

      // Switch to tube geometry mode (D_i, L).
      await tester.tap(find.text('From tube (Dᵢ, L)'));
      await tester.pump();
      expect(find.text('Inner radius of the pipe'), findsOneWidget);
      expect(
        find.text('Initial liquid volume inside the cylindrical tube'),
        findsOneWidget,
      );

      // Import tube dimensions from Heat transport (D_i = 50 mm, L = 10 m).
      await tester.tap(find.textContaining('Use tube from Heat transport'));
      await tester.pump();
      expect(find.textContaining('taken from Heat transport'), findsOneWidget);
    });
  });

  group('steam calculation', () {
    test('calculates enthalpies and stage heat from Tables A-4, A-5 and A-6 at 5 bar', () {
      // Defaults: P = 5 bar (500 kPa = 0.50 MPa), T₁ = 20 °C, T₂ = 200 °C.
      // Table A-4 at 20 °C: h₁ = 83.915 kJ/kg
      // Table A-5 at 500 kPa: T_sat = 151.83 °C, h_f = 640.09, h_fg = 2108.0, h_g = 2748.1 kJ/kg
      // Table A-6 at 0.50 MPa, 200 °C: h₂ = 2855.8 kJ/kg
      final result = calculateSteam(const SteamInputs());
      expect(result.tSat, closeTo(151.83, 1e-6));
      expect(result.h1, closeTo(83.915, 1e-6));
      expect(result.hf, closeTo(640.09, 1e-6));
      expect(result.hfg, closeTo(2108.0, 1e-6));
      expect(result.hg, closeTo(2748.1, 1e-6));
      expect(result.h2, closeTo(2855.8, 1e-6));
      expect(result.qLiquid, closeTo(640.09 - 83.915, 1e-6));
      expect(result.qEvaporation, closeTo(2748.1 - 640.09, 1e-6));
      expect(result.qSuperheat, closeTo(2855.8 - 2748.1, 1e-6));
      expect(result.qTotal, closeTo(2855.8 - 83.915, 1e-6));
      expect(result.temperaturesValid, isTrue);
      expect(result.isSuperheated, isTrue);
    });

    test(
      'saturated steam at T₂ = T_sat has h₂ = h_g and zero superheating heat',
      () {
        const inputs = SteamInputs(pressureBar: 1.01325);
        final saturated = inputs.copyWith(steamTemp: inputs.saturationTemp);
        final result = calculateSteam(saturated);
        expect(result.tSat, closeTo(99.97, 1e-6));
        expect(result.isSuperheated, isFalse);
        expect(result.h2, closeTo(result.hg, 1e-9));
        expect(result.qSuperheat, 0);
        expect(result.qTotal, closeTo(result.hg - result.h1, 1e-9));
      },
    );

    test(
      'steam flow rate (stoomdebiet) in ton/h and kg/s computes power in kW',
      () {
        // Default flow rate when enabled: 1.5 ton/h = 1500 / 3600 kg/s = 0.416666... kg/s.
        final withTonPerHour = calculateSteam(
          const SteamInputs(
            includeFlow: true,
            flowRate: 1.5,
            flowUnit: SteamFlowUnit.tonPerHour,
          ),
        );
        expect(
          withTonPerHour.massFlowKgPerS,
          closeTo(1.5 * 1000 / 3600, 1e-12),
        );
        expect(
          withTonPerHour.powerKw,
          closeTo((1.5 * 1000 / 3600) * withTonPerHour.qTotal, 1e-9),
        );
        expect(
          withTonPerHour.powerMw,
          closeTo(withTonPerHour.powerKw / 1000, 1e-12),
        );

        final withKgPerS = calculateSteam(
          const SteamInputs(
            includeFlow: true,
            flowRate: 0.5,
            flowUnit: SteamFlowUnit.kgPerSecond,
          ),
        );
        expect(withKgPerS.massFlowKgPerS, 0.5);
        expect(withKgPerS.powerKw, closeTo(0.5 * withKgPerS.qTotal, 1e-9));
      },
    );

    testWidgets(
      'opens Steam module, enables steam flow rate and selects stages',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const SemToolsApp(initialLocale: Locale('en')));
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Steam'),
          ),
        );
        await tester.pump();
        expect(find.text('Steam generation & T–h diagram'), findsOneWidget);
        expect(
          find.text('Isobaric enthalpy balance (Tables A-4, A-5 & A-6)'),
          findsOneWidget,
        );

        // Enable optional steam flow rate (defaults to 1.5 ton/h) and verify power in kW.
        await tester.ensureVisible(
          find.text('Include steam flow rate (calculate power in kW)'),
        );
        await tester.tap(
          find.text('Include steam flow rate (calculate power in kW)'),
        );
        await tester.pump();
        expect(find.widgetWithText(TextField, '1.5'), findsOneWidget);
        await tester.ensureVisible(find.text('Thermal power Q̇'));
        expect(find.text('Thermal power Q̇'), findsOneWidget);

        // Select evaporation stage from the table.
        await tester.ensureVisible(find.text('Evaporation (boiling)'));
        await tester.tap(find.text('Evaporation (boiling)'));
        await tester.pump();
        expect(find.text('Share of total'), findsOneWidget);
      },
    );

    testWidgets(
      'hovering points and stages on the T–h diagram displays kJ/kg, T and P',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(const SemToolsApp(initialLocale: Locale('en')));
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationRail),
            matching: find.text('Steam'),
          ),
        );
        await tester.pump();

        final paintFinder = find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is EnthalpyDiagramPainter,
        );
        expect(paintFinder, findsOneWidget);
        final rect = tester.getRect(paintFinder);
        final result = calculateSteam(const SteamInputs());
        final layout = EnthalpyDiagramLayout(size: rect.size, result: result);

        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        addTearDown(mouse.removePointer);

        // Hover over the start liquid point (h₁ at T₁ = 20 °C).
        final ptStart =
            rect.topLeft + layout.pointOffset(DiagramStatePoint.startLiquid);
        await mouse.moveTo(ptStart);
        await tester.pump();
        expect(find.text('Start liquid (Table A-4)'), findsOneWidget);
        expect(
          find.textContaining('83.92 kJ/kg', findRichText: true),
          findsOneWidget,
        );

        // Hover over the saturated liquid phase-change point (h_f at T_sat).
        final ptSatLiq =
            rect.topLeft +
            layout.pointOffset(DiagramStatePoint.saturatedLiquid);
        await mouse.moveTo(ptSatLiq);
        await tester.pump();
        expect(
          find.text('Saturated liquid — boiling starts (Table A-5)'),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Tₛₐₜ = 151.83 °C  ·  P = 5 bar (500 kPa)',
            findRichText: true,
          ),
          findsOneWidget,
        );

        // Hover over the short superheating bar (q₃) at the bottom of the diagram.
        final q3BarCenter =
            rect.topLeft + layout.stageBarRect(SteamStage.superheating).center;
        await mouse.moveTo(q3BarCenter);
        await tester.pump();
        expect(
          find.textContaining('107.70 kJ/kg', findRichText: true),
          findsWidgets,
        );
      },
    );
  });
}
