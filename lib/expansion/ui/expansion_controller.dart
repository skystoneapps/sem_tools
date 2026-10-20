import 'package:flutter/foundation.dart';

import '../domain/expansion_model.dart';

/// State of the expansion module, kept while the user visits other modules.
class ExpansionController extends ChangeNotifier {
  ExpansionInputs _inputs = const ExpansionInputs();
  bool _fromHeatTransfer = false;

  ExpansionInputs get inputs => _inputs;

  set inputs(ExpansionInputs value) {
    // Editing the tube dimensions by hand detaches them from Heat transport.
    if (value.innerDiameter != _inputs.innerDiameter ||
        value.length != _inputs.length) {
      _fromHeatTransfer = false;
    }
    _inputs = value;
    notifyListeners();
  }

  /// Whether the tube dimensions were imported from the heat transport module.
  bool get fromHeatTransfer => _fromHeatTransfer && _inputs.useTubeGeometry;

  /// Imports the tube inner diameter [innerDiameterMm] and [lengthM] from the
  /// heat transport module and switches to tube geometry mode.
  void importTube({required double innerDiameterMm, required double lengthM}) {
    _inputs = _inputs.copyWith(
      useTubeGeometry: true,
      innerDiameter: innerDiameterMm,
      length: lengthM,
    );
    _fromHeatTransfer = true;
    notifyListeners();
  }

  void reset() {
    _inputs = const ExpansionInputs();
    _fromHeatTransfer = false;
    notifyListeners();
  }
}
