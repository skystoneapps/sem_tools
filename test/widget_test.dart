import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:sem/heat_transfer/details_pane.dart';
import 'package:sem/heat_transfer/heat_model.dart';
import 'package:sem/heat_transfer/inputs_panel.dart';
import 'package:sem/main.dart';

void main() {
  group('calculateHeatTransfer', () {
    const inputs = TubeInputs();

    test('without radiation it matches a series hand calculation', () {
      final result = calculateHeatTransfer(inputs.copyWith(emissivity: 0));
      final l = inputs.length;
      final rTotal =
          1 / (inputs.hInner * 2 * math.pi * inputs.r1 * l) +
          math.log(inputs.r2 / inputs.r1) / (2 * math.pi * inputs.kPipe * l) +
          math.log(inputs.r3 / inputs.r2) /
              (2 * math.pi * inputs.kInsulation * l) +
          1 / (inputs.hOuter * 2 * math.pi * inputs.r3 * l);
      final expected = (inputs.fluidTemp - inputs.ambientTemp) / rTotal;
      expect(result.heatRate, closeTo(expected, 1e-6));
      expect(result.totalResistance, closeTo(rTotal, 1e-9));
      expect(result[HeatStage.outerRadiation].heatRate, 0);
    });

    test('energy balance holds at the surface with radiation', () {
      final result = calculateHeatTransfer(inputs);
      final conv = result[HeatStage.outerConvection];
      final rad = result[HeatStage.outerRadiation];
      final ins = result[HeatStage.insulationConduction];
      expect(conv.heatRate + rad.heatRate, closeTo(result.heatRate, 1e-6));
      expect(ins.deltaT / ins.resistance, closeTo(result.heatRate, 1e-6));
      expect(
        (result.fluidTemp - result.ambientTemp) / result.totalResistance,
        closeTo(result.heatRate, 1e-6),
      );
      expect(result.surfaceTemp, greaterThan(inputs.ambientTemp));
      expect(result.surfaceTemp, lessThan(inputs.fluidTemp));
    });

    test('heat flows inward when the fluid is colder than ambient', () {
      final result = calculateHeatTransfer(
        inputs.copyWith(fluidTemp: 5, ambientTemp: 25),
      );
      expect(result.heatRate, lessThan(0));
      expect(result.surfaceTemp, inInclusiveRange(5, 25));
    });

    test('no heat leaves without outer convection or radiation', () {
      final result = calculateHeatTransfer(
        inputs.copyWith(hOuter: 0, emissivity: 0),
      );
      expect(result.heatRate, closeTo(0, 1e-9));
      expect(result.surfaceTemp, closeTo(inputs.fluidTemp, 1e-6));
    });
  });

  testWidgets('result rows and the picker select the detailed stage', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
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

    await tester.pumpWidget(const MyApp(initialLocale: Locale('en')));
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

  testWidgets('hovering a formula symbol explains it', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp(initialLocale: Locale('en')));
    const message = 'Inner surface area of the pipe  [m²]';
    final symbol = find.byTooltip(message);
    expect(symbol, findsWidgets);
    // Units such as "m" or "K" are not treated as symbols.
    expect(find.byTooltip('m'), findsNothing);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(symbol.first));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text(message), findsOneWidget);
  });
}
