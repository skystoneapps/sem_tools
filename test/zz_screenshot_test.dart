
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sem/heat_transfer/details_pane.dart';
import 'package:sem/main.dart';

const fonts = '/Users/fre/fvm/versions/stable/bin/cache/artifacts/material_fonts';
const mathFonts = '/Users/fre/.pub-cache/hosted/pub.dev/flutter_math_fork-0.7.4/lib/katex_fonts/fonts';

Future<void> load(String family, List<String> paths) async {
  final l = FontLoader(family);
  for (final p in paths) {
    final b = File(p).readAsBytesSync();
    l.addFont(Future.value(ByteData.view(b.buffer)));
  }
  await l.load();
}

Future<void> loadFonts() async {
  await load('Roboto', ['$fonts/Roboto-Regular.ttf', '$fonts/Roboto-Medium.ttf', '$fonts/Roboto-Bold.ttf', '$fonts/Roboto-Italic.ttf']);
  await load('MaterialIcons', ['$fonts/MaterialIcons-Regular.otf']);
  final byFamily = <String, List<String>>{};
  for (final f in Directory(mathFonts).listSync().whereType<File>().where((f) => f.path.endsWith('.ttf'))) {
    final family = f.uri.pathSegments.last.replaceAll('.ttf', '').split('-').first;
    byFamily.putIfAbsent(family, () => []).add(f.path);
  }
  for (final e in byFamily.entries) {
    await load('packages/flutter_math_fork/${e.key}', e.value);
  }
}

final shotKey = GlobalKey();

Future<void> shot(WidgetTester tester, String name, {Future<void> Function()? act}) async {
  tester.view.physicalSize = const Size(1440, 1100);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(RepaintBoundary(key: shotKey, child: MyApp(key: UniqueKey(), initialLocale: const Locale('en'))));
  await tester.pump(const Duration(milliseconds: 400));
  if (act != null) await act();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.runAsync(() async {
    final img = await tester.renderObject<RenderRepaintBoundary>(find.byKey(shotKey)).toImage();
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    File('/private/tmp/claude-501/-Users-fre-Developer-Playground-sem/f3210614-4182-479e-a10e-0eceaef1d5c4/scratchpad/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

Future<void> pickTotal(WidgetTester tester) async {
  await tester.tap(find.descendant(of: find.byType(DetailsPane), matching: find.byIcon(Icons.arrow_drop_down)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.tap(find.widgetWithText(MenuItemButton, 'Total'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

void main() {
  testWidgets('shots', (tester) async {
    await tester.runAsync(loadFonts);
    await shot(tester, 'simplified', act: () async {
      await tester.tap(find.text('Constant fluid temperature (simplified)'));
      await tester.pump();
      await pickTotal(tester);
    });
    await shot(tester, 'simplified_invalid', act: () async {
      await tester.tap(find.text('Constant fluid temperature (simplified)'));
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextField, '0.1'), '0.0005');
      await tester.pump();
      await pickTotal(tester);
    });
    tester.view.reset();
  });
}
