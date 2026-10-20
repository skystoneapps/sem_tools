import 'package:flutter/foundation.dart';

import '../domain/steam_model.dart';

/// State of the steam module, kept while the user visits other modules.
class SteamController extends ChangeNotifier {
  SteamInputs _inputs = const SteamInputs();
  SteamStage? _selected;

  SteamInputs get inputs => _inputs;

  set inputs(SteamInputs value) {
    if (value == _inputs) return;
    _inputs = value;
    notifyListeners();
  }

  /// Stage shown in the detail pane (`null` shows the total derivation).
  SteamStage? get selected => _selected;

  set selected(SteamStage? value) {
    if (value == _selected) return;
    _selected = value;
    notifyListeners();
  }

  void reset() {
    _inputs = const SteamInputs();
    _selected = null;
    notifyListeners();
  }
}
