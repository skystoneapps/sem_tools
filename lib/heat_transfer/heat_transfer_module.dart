import 'package:flutter/material.dart';

import '../app/sem_module.dart';
import '../l10n/app_localizations.dart';
import 'heat_model.dart';
import 'heat_transfer_screen.dart';

/// State of the heat transport module, kept while the user visits other
/// modules.
class HeatTransferController extends ChangeNotifier {
  TubeInputs _inputs = const TubeInputs();
  HeatStage? _selected = HeatStage.innerConvection;
  int _resetCount = 0;

  TubeInputs get inputs => _inputs;

  set inputs(TubeInputs value) {
    _inputs = value;
    notifyListeners();
  }

  /// Stage shown in the detail pane; `null` shows the total.
  HeatStage? get selected => _selected;

  set selected(HeatStage? value) {
    _selected = value;
    notifyListeners();
  }

  /// Changes on every [reset], so input fields can rebuild from scratch.
  int get resetCount => _resetCount;

  void reset() {
    _inputs = const TubeInputs();
    _resetCount++;
    notifyListeners();
  }
}

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
