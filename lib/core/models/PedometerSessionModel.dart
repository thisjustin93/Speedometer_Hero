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

  PedometerSession({
    required this.sessionId,
    this.sessionDuration = Duration.zero,
    this.distanceInMeters = 0,
    this.startTime,
    this.endTime,
    this.speedInMS = 0,
    this.maxSpeedInMS = 0,
    this.averageSpeedInMS = 0,
    this.startPoint,
    this.endPoint,
    this.path,
    this.pauseDuration=Duration.zero,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'sessionDuration':
          sessionDuration.inMilliseconds, // Convert to milliseconds
      'pauseDuration':
          pauseDuration.inMilliseconds, // Convert to milliseconds
      'distanceInMeters': distanceInMeters,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'speedInMS': speedInMS,
      'maxSpeedInMS': maxSpeedInMS,
      'averageSpeedInMS': averageSpeedInMS,
      'startPoint': startPoint?.toJson(),
      'endPoint': endPoint?.toJson(),
      'path': path?.toJson(),
    };
  }

  PedometerSession.fromMap(Map<String, dynamic> map) {
    sessionId = map['sessionId'];
    sessionDuration = Duration(
        milliseconds: map['sessionDuration']); // Convert back to Duration
    pauseDuration = Duration(
        milliseconds: map['pauseDuration']); // Convert back to Duration
    startTime =
        map['startTime'] != null ? DateTime.parse(map['startTime']) : null;
    distanceInMeters = map['distanceInMeters'];
    endTime = map['endTime'] != null ? DateTime.parse(map['endTime']) : null;
    speedInMS = map['speedInMS'];
    maxSpeedInMS = map['maxSpeedInMS'];
    averageSpeedInMS = map['averageSpeedInMS'];
    startPoint =
        map['startPoint'] != null ? LatLng.fromJson(map['startPoint']) : null;
    endPoint =
        map['endPoint'] != null ? LatLng.fromJson(map['endPoint']) : null;
    final List<dynamic>? pointsJson = map['path'];
    path = Polyline(
      polylineId: PolylineId(sessionId),
      points:
          pointsJson!.map((point) => LatLng.fromJson(point)!).toList() ?? [],
    );
  }
}
