import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// A tool in SEM tools. The app shell lists every module in its navigation,
/// shows [pageTitle] and [buildActions] in the top bar and [buildPage] below
/// it.
///
/// A module lives as long as the shell, so state kept on the module itself
/// (such as a controller) survives switching to another module and back.
abstract class SemModule {
  IconData get icon;
  IconData get selectedIcon;

  /// Short name for the navigation.
  String title(AppLocalizations l10n);

  /// One-line explanation for the overview page.
  String description(AppLocalizations l10n);

  /// Title in the top bar while the module is open.
  String pageTitle(AppLocalizations l10n) => title(l10n);

  Widget buildPage(BuildContext context);

  /// Module-specific buttons for the top bar, before the language picker.
  List<Widget> buildActions(BuildContext context) => const [];

  void dispose() {}
}
