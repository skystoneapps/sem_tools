import 'package:flutter/foundation.dart';

import '../domain/heat_model.dart';

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
