import 'package:flutter/material.dart';

import '../app/sem_module.dart';
import '../heat_transfer/heat_transfer_module.dart';
import '../l10n/app_localizations.dart';
import 'price_model.dart';
import 'price_screen.dart';

/// State of the price module, kept while the user visits other modules.
class PriceController extends ChangeNotifier {
  PriceInputs _inputs = const PriceInputs();
  double? _tubeLength;

  PriceInputs get inputs => _inputs;

  set inputs(PriceInputs value) {
    // A heat loss typed by hand no longer belongs to a known tube.
    if (value.power != _inputs.power) _tubeLength = null;
    _inputs = value;
    notifyListeners();
  }

  /// Length of the tube the heat loss was taken from, when it was imported
  /// from the heat transport module; enables the cost per metre.
  double? get tubeLength => _tubeLength;

  /// Takes the heat loss [power] of a tube of [length] metres.
  void importHeatLoss(double power, double length) {
    _inputs = _inputs.copyWith(power: power);
    _tubeLength = length;
    notifyListeners();
  }

  void reset() {
    _inputs = const PriceInputs();
    _tubeLength = null;
    notifyListeners();
  }
}

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
