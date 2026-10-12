import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app/app_shell.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const SemToolsApp());
}

/// SEM tools: a collection of engineering calculation modules sharing one
/// language setting.
class SemToolsApp extends StatefulWidget {
  const SemToolsApp({super.key, this.initialLocale});

  /// Language to start in; `null` follows the system language, falling back
  /// to English when it is not supported.
  final Locale? initialLocale;

  @override
  State<SemToolsApp> createState() => _SemToolsAppState();
}

class _SemToolsAppState extends State<SemToolsApp> {
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
      home: AppShell(
        onLocaleChanged: (locale) => setState(() => _locale = locale),
      ),
    );
  }
}
