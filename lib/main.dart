import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'heat_transfer/heat_transfer_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.initialLocale});

  /// Language to start in; `null` follows the system language, falling back
  /// to English when it is not supported.
  final Locale? initialLocale;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale? _locale = widget.initialLocale;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2F6F8F);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      builder: (context, child) {
        // Number formatting (decimal separator) follows the active language.
        Intl.defaultLocale = Localizations.localeOf(context).toLanguageTag();
        return child!;
      },
      home: HeatTransferScreen(
        onLocaleChanged: (locale) => setState(() => _locale = locale),
      ),
    );
  }
}
