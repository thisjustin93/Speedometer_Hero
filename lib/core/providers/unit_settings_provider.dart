import 'package:flutter/material.dart';
import 'package:speedometer/core/models/SettingsModel.dart';

class UnitsProvider extends ChangeNotifier {
  // String speedUnit = "mph";
  // String elevationUnit = "ft";
  // bool showCompass = true;
  // bool showElevation = true;
  // bool showCityName = true;
  // int maximumGaugeSpeed = 200;
  // bool liveActivity = true;
  // bool darkTheme = false;
  SettingsModel settings = SettingsModel();
  setAllUnits(SettingsModel settings) {
    this.settings = settings;
    // speedUnit = settings.speedUnit;
    // elevationUnit = settings.elevationUnit;
    // showCompass = settings.showCompass;
    // showElevation = settings.showElevation;
    // showCityName = settings.showCityName;
    // maximumGaugeSpeed = settings.maximumGaugeSpeed;
    // liveActivity = settings.liveActivity;
    // darkTheme = settings.darkTheme;
    notifyListeners();
  }

  // setSpeedUnit(String unit) {
  //   speedUnit = unit;
  //   notifyListeners();
  // }

  // setElevationUnit(String unit) {
  //   elevationUnit = unit;
  //   notifyListeners();
  // }

  // setShowCompass(bool show) {
  //   showCompass = show;
  //   notifyListeners();
  // }

  // setShowElevation(bool show) {
  //   showElevation = show;
  //   notifyListeners();
  // }

  // setShowCityName(bool show) {
  //   showCityName = show;
  //   notifyListeners();
  // }

  // changeMaximumGaugeSpeed(bool increase) {
  //   if (increase) {
  //     maximumGaugeSpeed += 1;
  //   } else {
  //     maximumGaugeSpeed -= 1;
  //   }
  //   notifyListeners();
  // }

  // setLiveActivity(bool show) {
  //   liveActivity = show;
  //   notifyListeners();
  // }

  // setDarkTheme(bool show) {
  //   darkTheme = show;
  //   notifyListeners();
  // }
}
