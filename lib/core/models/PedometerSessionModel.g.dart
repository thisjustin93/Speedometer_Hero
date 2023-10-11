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
      sessionDuration: Duration(milliseconds: fields[3] as int),
      pauseDuration: Duration(milliseconds: fields[11] as int),
      distanceInMeters: fields[9] as double,
      startTime:DateTime.fromMillisecondsSinceEpoch(fields[1]),
      endTime: DateTime.fromMillisecondsSinceEpoch(fields[2]),
      speedInMS: fields[4] as double,
      maxSpeedInMS: fields[5] as double,
      averageSpeedInMS: fields[6] as double,
      startPoint: _deserializeLatLng(fields[7]),
      endPoint: _deserializeLatLng(fields[8]),
      path: _deserializePolyline(fields[10]),
    );
  }

  @override
  void write(BinaryWriter writer, PedometerSession obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.startTime?.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.endTime?.millisecondsSinceEpoch)
      ..writeByte(3)
      ..write(obj.sessionDuration.inMilliseconds)
      ..writeByte(4)
      ..write(obj.speedInMS)
      ..writeByte(5)
      ..write(obj.maxSpeedInMS)
      ..writeByte(6)
      ..write(obj.averageSpeedInMS)
      ..writeByte(7)
      ..write(_serializeLatLng(obj.startPoint))
      ..writeByte(8)
      ..write(_serializeLatLng(obj.endPoint))
      ..writeByte(9)
      ..write(obj.distanceInMeters)
      ..writeByte(10)
      ..write(_serializePolyline(obj.path))
      ..writeByte(11)
      ..write(obj.pauseDuration.inMilliseconds);
  }

  LatLng? _deserializeLatLng(dynamic value) {
    if (value != null) {
      final Map<String, dynamic> data =Map<String,dynamic>.from(value);
      return LatLng(data['latitude'] as double, data['longitude'] as double);
    }
    return null;
  }

  Map<String, double>? _serializeLatLng(LatLng? value) {
    if (value != null) {
      return {'latitude': value.latitude, 'longitude': value.longitude};
    }
    return null;
  }

  Polyline? _deserializePolyline(dynamic value) {
    if (value != null) {
      final Map<String, dynamic> data = Map<String,dynamic>.from(value);
      return Polyline(
        polylineId: PolylineId(data['polylineId'] as String),
        points: List<LatLng>.from(
          (data['points'] as List).map(
            (point) => LatLng(point['latitude'] as double, point['longitude'] as double),
          ),
        ),
      );
    }
    return null;
  }

  Map<String, dynamic>? _serializePolyline(Polyline? value) {
    if (value != null) {
      return {
        'polylineId': value.polylineId.value,
        'points': value.points.map((point) => _serializeLatLng(point)).toList(),
      };
    }
    return null;
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

