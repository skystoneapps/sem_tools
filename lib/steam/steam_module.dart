import 'package:flutter/material.dart';

import '../app/sem_module.dart';
import '../l10n/app_localizations.dart';
import 'ui/steam_controller.dart';
import 'ui/steam_screen.dart';

class SteamModule extends SemModule {
  final controller = SteamController();

  @override
  IconData get icon => Icons.cloud_outlined;

  @override
  IconData get selectedIcon => Icons.cloud;

  @override
  String title(AppLocalizations l10n) => l10n.moduleSteamTitle;

  @override
  String description(AppLocalizations l10n) => l10n.moduleSteamDescription;

  @override
  String pageTitle(AppLocalizations l10n) => l10n.moduleSteamPageTitle;

  @override
  Widget buildPage(BuildContext context) => SteamScreen(controller: controller);

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      tooltip: AppLocalizations.of(context).resetTooltip,
      onPressed: controller.reset,
      icon: const Icon(Icons.restart_alt),
    ),
  ];

  @override
  void dispose() => controller.dispose();
}

