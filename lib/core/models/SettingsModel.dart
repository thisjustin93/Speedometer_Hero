import 'package:flutter/physics.dart';
import 'package:hive/hive.dart';

part 'SettingsModel.g.dart';

@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String speedUnit = "mph";

  @HiveField(1)
  String elevationUnit = "ft";

  @HiveField(2)
  bool showCompass = true;

  @HiveField(3)
  bool showElevation = true;

  @HiveField(4)
  bool showCityName = true;

  @HiveField(5)
  int maximumGaugeSpeed = 200;

  @HiveField(6)
  bool liveActivity = true;

  @HiveField(7)
  bool? darkTheme;
  SettingsModel({
    this.speedUnit = "mph",
    this.elevationUnit = "ft",
    this.showCompass = true,
    this.showElevation = true,
    this.showCityName = true,
    this.maximumGaugeSpeed = 200,
    this.liveActivity = true,
    this.darkTheme,
  });

  Map<String, dynamic> toMap() {
    return {
      'speedUnit': speedUnit,
      'elevationUnit': elevationUnit,
      'showCompass': showCompass,
      'showElevation': showElevation,
      'showCityName': showCityName,
      'maximumGaugeSpeed': maximumGaugeSpeed,
      'liveActivity': liveActivity,
      'darkTheme': darkTheme,
    };
  }

  SettingsModel.fromMap(Map<String, dynamic> map) {
    speedUnit = map['speedUnit'] ?? "mph";
    elevationUnit = map['elevationUnit'] ?? "ft";
    showCompass = map['showCompass'] ?? true;
    showElevation = map['showElevation'] ?? true;
    showCityName = map['showCityName'] ?? true;
    maximumGaugeSpeed = map['maximumGaugeSpeed'] ?? 200;
    liveActivity = map['liveActivity'] ?? true;
    darkTheme = map['darkTheme'] ?? false;
  }
}
