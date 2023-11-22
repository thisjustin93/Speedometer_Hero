// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PedometerSessionModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PedometerSessionAdapter extends TypeAdapter<PedometerSession> {
  @override
  final int typeId = 0;

  @override
  PedometerSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PedometerSession(
      sessionId: fields[0] as String,
      sessionTitle: fields[12] as String,
      sessionDuration: fields[3] as Duration,
      distanceInMeters: fields[9] as double,
      startTime: fields[1] as DateTime?,
      endTime: fields[2] as DateTime?,
      altitude: fields[13] as double,
      speedInMS: fields[4] as double,
      maxSpeedInMS: fields[5] as double,
      averageSpeedInMS: fields[6] as double,
      startPoint: fields[7] as LatLng?,
      endPoint: fields[8] as LatLng?,
      path: fields[10] as Polyline?,
      pauseDuration: fields[11] as Duration,
      activityType: fields[14] as String?,
      note: fields[15] as String?,
      geoPositions: (fields[16] as List?)?.cast<Position>(),
    );
  }

  @override
  void write(BinaryWriter writer, PedometerSession obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.sessionDuration)
      ..writeByte(4)
      ..write(obj.speedInMS)
      ..writeByte(5)
      ..write(obj.maxSpeedInMS)
      ..writeByte(6)
      ..write(obj.averageSpeedInMS)
      ..writeByte(7)
      ..write(obj.startPoint)
      ..writeByte(8)
      ..write(obj.endPoint)
      ..writeByte(9)
      ..write(obj.distanceInMeters)
      ..writeByte(10)
      ..write(obj.path)
      ..writeByte(11)
      ..write(obj.pauseDuration)
      ..writeByte(12)
      ..write(obj.sessionTitle)
      ..writeByte(13)
      ..write(obj.altitude)
      ..writeByte(14)
      ..write(obj.activityType)
      ..writeByte(15)
      ..write(obj.note)
      ..writeByte(16)
      ..write(obj.geoPositions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PedometerSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
