import 'package:flutter/material.dart';
import 'package:speedometer/core/models/SettingsModel.dart';

class UnitsProvider extends ChangeNotifier {
  SettingsModel settings = SettingsModel();
  setAllUnits(SettingsModel settings) {
    this.settings = settings;

    notifyListeners();
  }
}
