// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SettingsModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 1;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      speedUnit: fields[0] as String,
      elevationUnit: fields[1] as String,
      showCompass: fields[2] as bool,
      showElevation: fields[3] as bool,
      showCityName: fields[4] as bool,
      maximumGaugeSpeed: fields[5] as int,
      liveActivity: fields[6] as bool,
      darkTheme: fields[7] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.speedUnit)
      ..writeByte(1)
      ..write(obj.elevationUnit)
      ..writeByte(2)
      ..write(obj.showCompass)
      ..writeByte(3)
      ..write(obj.showElevation)
      ..writeByte(4)
      ..write(obj.showCityName)
      ..writeByte(5)
      ..write(obj.maximumGaugeSpeed)
      ..writeByte(6)
      ..write(obj.liveActivity)
      ..writeByte(7)
      ..write(obj.darkTheme);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
