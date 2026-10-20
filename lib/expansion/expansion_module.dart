import 'package:flutter/material.dart';

import '../app/sem_module.dart';
import '../heat_transfer/ui/heat_transfer_controller.dart';
import '../l10n/app_localizations.dart';
import 'ui/expansion_controller.dart';
import 'ui/expansion_screen.dart';

class ExpansionModule extends SemModule {
  ExpansionModule({required this.heatTransfer});

  /// Source of the tube geometry that can be imported as system volume.
  final HeatTransferController heatTransfer;

  final controller = ExpansionController();

  @override
  IconData get icon => Icons.expand_outlined;

  @override
  IconData get selectedIcon => Icons.expand;

  @override
  String title(AppLocalizations l10n) => l10n.moduleExpansionTitle;

  @override
  String description(AppLocalizations l10n) => l10n.moduleExpansionDescription;

  @override
  String pageTitle(AppLocalizations l10n) => l10n.moduleExpansionPageTitle;

  @override
  Widget buildPage(BuildContext context) =>
      ExpansionScreen(controller: controller, heatTransfer: heatTransfer);

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
