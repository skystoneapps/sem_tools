import 'package:flutter/material.dart';

import '../app/sem_module.dart';
import '../l10n/app_localizations.dart';
import 'ui/heat_transfer_controller.dart';
import 'ui/heat_transfer_screen.dart';

class HeatTransferModule extends SemModule {
  final controller = HeatTransferController();

  @override
  IconData get icon => Icons.thermostat_outlined;

  @override
  IconData get selectedIcon => Icons.thermostat;

  @override
  String title(AppLocalizations l10n) => l10n.moduleHeatTransfer;

  @override
  String description(AppLocalizations l10n) =>
      l10n.moduleHeatTransferDescription;

  @override
  String pageTitle(AppLocalizations l10n) => l10n.screenTitle;

  @override
  Widget buildPage(BuildContext context) =>
      HeatTransferScreen(controller: controller);

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
