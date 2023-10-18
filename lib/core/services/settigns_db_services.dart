import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:speedometer/core/models/SettingsModel.dart';

class HiveSettingsDB {
  Future<void> init() async {
    await Hive.openBox<SettingsModel>('settings');
    final settingsBox = Hive.box<SettingsModel>('settings');

    if (settingsBox.isEmpty) {
      await settingsBox.add(SettingsModel());
    }
  }

  Future<SettingsModel> getSettings(bool isDarkTheme) async {
    

    final settingsBox = await Hive.openBox<SettingsModel>('settings');
    if (settingsBox.isNotEmpty) {
      return settingsBox.getAt(0)!;
    } else {
      await settingsBox.add(SettingsModel(darkTheme: isDarkTheme));
    }
    return SettingsModel(darkTheme: isDarkTheme); // Return default settings if none found
  }

  Future updateSettings(SettingsModel newSettings) async {
    final settingsBox = await Hive.openBox<SettingsModel>('settings');
    if (settingsBox.isNotEmpty) {
      await settingsBox.putAt(0, newSettings);
    } else {
      await init();
    }
  }

  void deleteSettings() async {
    final settingsBox = await Hive.openBox<SettingsModel>('settings');
    if (settingsBox.isNotEmpty) {
      await settingsBox.deleteAt(0);
    }
  }
}
