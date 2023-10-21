import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
part 'PedometerSessionModel.g.dart';

@HiveType(typeId: 0)
class PedometerSession extends HiveObject {
  @HiveField(0)
  late String sessionId;

  @HiveField(1)
  late DateTime? startTime;

  @HiveField(2)
  late DateTime? endTime;

  @HiveField(3)
  late Duration sessionDuration;

  @HiveField(4)
  late double speedInMS;

  @HiveField(5)
  late double maxSpeedInMS;

  @HiveField(6)
  late double averageSpeedInMS;

  @HiveField(7)
  late LatLng? startPoint;

  @HiveField(8)
  late LatLng? endPoint;

  @HiveField(9)
  late double distanceInMeters;

  @HiveField(10)
  late Polyline? path;

  @HiveField(11)
  late Duration pauseDuration;
  @HiveField(12)
  late String sessionTitle;
  @HiveField(13)
  late double altitude;
  @HiveField(14)
  late String? activityType;
  @HiveField(15)
  late String? note;
  @HiveField(16)
  late List<Position>? geoPositions;

  PedometerSession(
      {required this.sessionId,
      required this.sessionTitle,
      this.sessionDuration = Duration.zero,
      this.distanceInMeters = 0,
      this.startTime,
      this.endTime,
      this.altitude = 0,
      this.speedInMS = 0,
      this.maxSpeedInMS = 0,
      this.averageSpeedInMS = 0,
      this.startPoint,
      this.endPoint,
      this.path,
      this.pauseDuration = Duration.zero,
      this.activityType,
      this.note,
      this.geoPositions});

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'sessionTitle': sessionTitle,
      'sessionDuration':
          sessionDuration.inMilliseconds, // Convert to milliseconds
      'pauseDuration': pauseDuration.inMilliseconds, // Convert to milliseconds
      'distanceInMeters': distanceInMeters,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'speedInMS': speedInMS,
      'altitude': altitude,
      'maxSpeedInMS': maxSpeedInMS,
      'averageSpeedInMS': averageSpeedInMS,
      'startPoint': [startPoint!.latitude, startPoint!.longitude],
      'endPoint': [endPoint!.latitude, endPoint!.longitude],
      'path': path!.toJson(),
      'activityType': activityType,
      'note': note,
      'geoPositions': geoPositions,
    };
  }

  PedometerSession.fromMap(Map<String, dynamic> map) {
    sessionId = map['sessionId'];
    sessionTitle = map['sessionTitle'];
    sessionDuration = Duration(
        milliseconds: map['sessionDuration']); // Convert back to Duration
    pauseDuration = Duration(
        milliseconds: map['pauseDuration']); // Convert back to Duration
    startTime =
        map['startTime'] != null ? DateTime.parse(map['startTime']) : null;
    distanceInMeters = map['distanceInMeters'];
    endTime = map['endTime'] != null ? DateTime.parse(map['endTime']) : null;
    speedInMS = map['speedInMS'];
    activityType = map['activityType'];
    note = map['note'];
    maxSpeedInMS = map['maxSpeedInMS'];
    altitude = map['altitude'];
    averageSpeedInMS = map['averageSpeedInMS'];
    startPoint =
        map['startPoint'] != null ? LatLng.fromJson(map['startPoint']) : null;
    endPoint =
        map['endPoint'] != null ? LatLng.fromJson(map['endPoint']) : null;
    final List<dynamic>? pointsJson = map['path'];
    // path =
    path = Polyline(
      polylineId: PolylineId("$sessionId"),
      points:
          pointsJson!.map((point) => LatLng.fromJson(point)!).toList() ?? [],
    );
    geoPositions = map['geoPositions'];
  }

  // Object toJson(Polyline polyline) {
  //   final Map<String, Object> json = <String, Object>{};

  //   void addIfPresent(String fieldName, Object? value) {
  //     if (value != null) {
  //       json[fieldName] = value;
  //     }
  //   }

  //   addIfPresent('polylineId', polyline.polylineId.value);
  //   addIfPresent('consumeTapEvents', polyline.consumeTapEvents);
  //   addIfPresent('color', polyline.color.value);
  //   addIfPresent('endCap', polyline.endCap.toJson());
  //   addIfPresent('geodesic', polyline.geodesic);
  //   addIfPresent('jointType', polyline.jointType.value);
  //   addIfPresent('startCap', polyline.startCap.toJson());
  //   addIfPresent('visible', polyline.visible);
  //   addIfPresent('width', polyline.width);
  //   addIfPresent('zIndex', polyline.zIndex);

  //   json['points'] = _pointsToJson(polyline.points);

  //   json['pattern'] = _patternToJson(polyline.patterns);

  //   return json;
  // }

  // Object _pointsToJson(List<LatLng> points) {
  //   final List<Object> result = <Object>[];
  //   for (final LatLng point in points) {
  //     result.add(point.toJson());
  //   }
  //   return result;
  // }

  // Object _patternToJson(List<PatternItem> patterns) {
  //   final List<Object> result = <Object>[];
  //   for (final PatternItem patternItem in patterns) {
  //     result.add(patternItem.toJson());
  //   }
  //   return result;
  // }
}

// // import 'package:apple_maps_flutter/apple_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:hive/hive.dart';

// part 'PedometerSessionModel.g.dart';

// @HiveType(typeId: 0)
// class PedometerSession extends HiveObject {
//   @HiveField(0)
//   late String sessionId;

//   @HiveField(1)
//   late DateTime? startTime;

//   @HiveField(2)
//   late DateTime? endTime;

//   @HiveField(3)
//   late Duration sessionDuration;

//   @HiveField(4)
//   late double speedInMS;

//   @HiveField(5)
//   late double maxSpeedInMS;

//   @HiveField(6)
//   late double averageSpeedInMS;

//   @HiveField(7)
//   late LatLng? startPoint;

//   @HiveField(8)
//   late LatLng? endPoint;

//   @HiveField(9)
//   late double distanceInMeters;

//   @HiveField(10)
//   late Polyline? path;

//   @HiveField(11)
//   late Duration pauseDuration;
//   @HiveField(12)
//   late String sessionTitle;
//   @HiveField(13)
//   late double altitude;
//   @HiveField(14)
//   late String? activityType;
//   @HiveField(15)
//   late String? note;
//   @HiveField(16)
//   late List<Position>? geoPositions;

//   PedometerSession(
//       {required this.sessionId,
//       required this.sessionTitle,
//       this.sessionDuration = Duration.zero,
//       this.distanceInMeters = 0,
//       this.startTime,
//       this.endTime,
//       this.altitude = 0,
//       this.speedInMS = 0,
//       this.maxSpeedInMS = 0,
//       this.averageSpeedInMS = 0,
//       this.startPoint,
//       this.endPoint,
//       this.path,
//       this.pauseDuration = Duration.zero,
//       this.activityType,
//       this.note,
//       this.geoPositions});

//   Map<String, dynamic> toMap() {
//     return {
//       'sessionId': sessionId,
//       'sessionTitle': sessionTitle,
//       'sessionDuration':
//           sessionDuration.inMilliseconds, // Convert to milliseconds
//       'pauseDuration': pauseDuration.inMilliseconds, // Convert to milliseconds
//       'distanceInMeters': distanceInMeters,
//       'startTime': startTime?.toIso8601String(),
//       'endTime': endTime?.toIso8601String(),
//       'speedInMS': speedInMS,
//       'altitude': altitude,
//       'maxSpeedInMS': maxSpeedInMS,
//       'averageSpeedInMS': averageSpeedInMS,
//       'startPoint': toJson(startPoint!.latitude,startPoint!.longitude),
//       'endPoint':toJson(endPoint!.latitude,endPoint!.longitude),
//       'path': pathtoJson(path),
//       'activityType': activityType,
//       'note': note,
//       'geoPositions': geoPositions,
//     };
//   }

//   PedometerSession.fromMap(Map<String, dynamic> map) {
//     sessionId = map['sessionId'];
//     sessionTitle = map['sessionTitle'];
//     sessionDuration = Duration(
//         milliseconds: map['sessionDuration']); // Convert back to Duration
//     pauseDuration = Duration(
//         milliseconds: map['pauseDuration']); // Convert back to Duration
//     startTime =
//         map['startTime'] != null ? DateTime.parse(map['startTime']) : null;
//     distanceInMeters = map['distanceInMeters'];
//     endTime = map['endTime'] != null ? DateTime.parse(map['endTime']) : null;
//     speedInMS = map['speedInMS'];
//     activityType = map['activityType'];
//     note = map['note'];
//     maxSpeedInMS = map['maxSpeedInMS'];
//     altitude = map['altitude'];
//     averageSpeedInMS = map['averageSpeedInMS'];
//     startPoint =
//         map['startPoint'] != null ?fromJson(map['startPoint']) : null;
//     endPoint =
//         map['endPoint'] != null ? fromJson(map['endPoint']) : null;
//     final List<dynamic>? pointsJson = map['path'];
//     path = Polyline(
//       polylineId: PolylineId("$sessionId"),
//       points:
//           pointsJson!.map((point) => fromJson(point)!).toList() ?? [],
//     );
//     geoPositions = map['geoPositions'];
//   }

//     static LatLng? fromJson(Object? json) {
//     if (json == null) {
//       return null;
//     }
//     assert(json is List && json.length == 2);
//     final List<Object?> list = json as List<Object?>;
//     return LatLng(list[0]! as double, list[1]! as double);
//   }

// Object toJson(double latitude,double longitude) {
//     return <double>[latitude, longitude];
//   }
//     Object pathtoJson(Polyline path) {
//     final Map<String, Object> json = <String, Object>{};

//     void addIfPresent(String fieldName, Object? value) {
//       if (value != null) {
//         json[fieldName] = value;
//       }
//     }

//     addIfPresent('polylineId', path.polylineId.value);
//     addIfPresent('consumeTapEvents', path.consumeTapEvents);
//     addIfPresent('color', path.color.value);
//     addIfPresent('endCap', path.endCap.toJson());
//     addIfPresent('geodesic', path.geodesic);
//     addIfPresent('jointType', path.jointType.value);
//     addIfPresent('startCap', path.startCap.toJson());
//     addIfPresent('visible', path.visible);
//     addIfPresent('width', path.width);
//     addIfPresent('zIndex', path.zIndex);

//     json['points'] = _pointsToJson();

//     json['pattern'] = _patternToJson();

//     return json;
//   }
//    Object _pointsToJson() {
//     final List<Object> result = <Object>[];
//     for (final LatLng point in points) {
//       result.add(point.toJson());
//     }
//     return result;
//   }
// }
