import 'package:flutter/material.dart';

import '../app/sem_module.dart';
import '../heat_transfer/ui/heat_transfer_controller.dart';
import '../l10n/app_localizations.dart';
import 'ui/price_controller.dart';
import 'ui/price_screen.dart';

class PriceModule extends SemModule {
  PriceModule({required this.heatTransfer});

  /// Source of the heat loss that can be imported.
  final HeatTransferController heatTransfer;

  final controller = PriceController();

  @override
  IconData get icon => Icons.payments_outlined;

  @override
  IconData get selectedIcon => Icons.payments;

  @override
  String title(AppLocalizations l10n) => l10n.modulePrice;

  @override
  String description(AppLocalizations l10n) => l10n.modulePriceDescription;

  @override
  String pageTitle(AppLocalizations l10n) => l10n.modulePriceTitle;

  @override
  Widget buildPage(BuildContext context) =>
      PriceScreen(controller: controller, heatTransfer: heatTransfer);

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
