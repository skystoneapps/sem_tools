import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:sem/heat_transfer/ui/details_pane.dart';
import 'package:sem/common/ui/number_format.dart';
import 'package:sem/heat_transfer/domain/heat_model.dart';
import 'package:sem/heat_transfer/ui/inputs_panel.dart';
import 'package:sem/main.dart';
import 'package:sem/price/domain/price_model.dart';
import 'package:sem/price/ui/price_controller.dart';

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
}
