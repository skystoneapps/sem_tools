import 'package:flutter/foundation.dart';

import '../domain/price_model.dart';

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
