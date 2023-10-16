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
      activityType: fields[14] as String,
      note: fields[15] as String,
      geoPositions: _deserializePositions(fields[16]),
      sessionDuration: Duration(milliseconds: fields[3] as int),
      pauseDuration: Duration(milliseconds: fields[11] as int),
      distanceInMeters: fields[9] as double,
      startTime: DateTime.fromMillisecondsSinceEpoch(fields[1]),
      endTime: DateTime.fromMillisecondsSinceEpoch(fields[2]),
      speedInMS: fields[4] as double,
      altitude: fields[13] as double,
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
      ..writeByte(17)
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
      ..write(obj.pauseDuration.inMilliseconds)
      ..writeByte(12)
      ..write(obj.sessionTitle)
      ..writeByte(13)
      ..write(obj.altitude)
      ..writeByte(14)
      ..write(obj.activityType)
      ..writeByte(15)
      ..write(obj.note)
      ..writeByte(16)
      ..write(_serializePositions(obj.geoPositions));
  }

  List<Map<String, dynamic>>? _serializePositions(List<Position>? value) {
    if (value != null) {
      return value.map((position) => _serializePosition(position)).toList();
    }
    return null;
  }

  List<Position>? _deserializePositions(dynamic value) {
    if (value != null) {
      final List<Map<String, dynamic>> data =
          value.map<Map<String, dynamic>>((e) {
        return Map<String, dynamic>.from(e);
      }).toList();
      // List<Map<String, dynamic>>.from(value);

      return data.map((map) => _deserializePosition(map)).toList();
    }
    return null;
  }

  Position _deserializePosition(dynamic value) {
    // if (value != null) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(value);
    return Position(
      latitude: data['latitude'] as double,
      longitude: data['longitude'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
      accuracy: data['accuracy'] as double,
      altitude: data['altitude'] as double,
      altitudeAccuracy: data['altitudeAccuracy'] as double,
      heading: data['heading'] as double,
      headingAccuracy: data['headingAccuracy'] as double,
      speed: data['speed'] as double,
      speedAccuracy: data['speedAccuracy'] as double,
      floor: data['floor'] as int?,
      isMocked: data['isMocked'] as bool,

      // Deserialize other Position properties here
    );
    // }
    // return null;
  }

  Map<String, dynamic> _serializePosition(Position value) {
    // if (value != null) {
    return {
      'latitude': value.latitude,
      'longitude': value.longitude,
      'timestamp': value.timestamp!.millisecondsSinceEpoch,
      'accuracy': value.accuracy,
      'altitude': value.altitude,
      'altitudeAccuracy': value.altitudeAccuracy,
      'heading': value.heading,
      'headingAccuracy': value.headingAccuracy,
      'speed': value.speed,
      'speedAccuracy': value.speedAccuracy,
      'floor': value.floor,
      'isMocked': value.isMocked,
      // Serialize other Position properties here
    };
    // }
    // return null;
  }

  LatLng? _deserializeLatLng(dynamic value) {
    if (value != null) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(value);
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
      final Map<String, dynamic> data = Map<String, dynamic>.from(value);
      return Polyline(
        polylineId: PolylineId(data['polylineId'] as String),
        points: List<LatLng>.from(
          (data['points'] as List).map(
            (point) => LatLng(
                point['latitude'] as double, point['longitude'] as double),
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
