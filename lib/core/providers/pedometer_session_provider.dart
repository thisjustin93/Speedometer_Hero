import 'dart:async';
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:location/location.dart' as location;

class PedoMeterSessionProvider extends ChangeNotifier {
  List<PedometerSession> pedometerSessions = [];
  PedometerSession? currentPedometerSession;
  bool isTracking = false;
  DateTime? pauseTime;
  DateTime? startTime;

  void setCurrentPedometerSession(PedometerSession pedometerSession) {
    currentPedometerSession = pedometerSession;
    notifyListeners();
  }

  void updatePedometerSessionList(List<PedometerSession> pedometerSessions) {
    this.pedometerSessions = pedometerSessions;
    this.pedometerSessions = this.pedometerSessions.reversed.toList();
    notifyListeners();
  }

  StreamSubscription<Position>? geolocatorStream;

  void startTracking() async {
    var status = await Geolocator.checkPermission();

    if (status == LocationPermission.denied ||
        status == LocationPermission.deniedForever ||
        status == LocationPermission.unableToDetermine) {
      await Geolocator.requestPermission();
    }

    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      final result = await location.Location().requestService();
      if (result == true) {
        print('Service has been enabled');
      } else {
        print('Service has not been enabled');
      }
    }

    if (currentPedometerSession == null) {
      currentPedometerSession = PedometerSession(
          sessionId: DateTime.now().toString(),
          sessionTitle: "",
          geoPositions: [await Geolocator.getCurrentPosition()]);
      if (currentPedometerSession!.geoPositions == null) {
        currentPedometerSession!.geoPositions = [
          await Geolocator.getCurrentPosition()
        ];
      }
    }
    // Timer.periodic(Duration(seconds: 1), (timer) {
    //   notifyListeners();
    // });
    if (startTime == null) {
      startTime = DateTime.now();
      notifyListeners();
    }
    geolocatorStream = null;

    final geolocator = Geolocator();

    // List<LatLng> points = []
    final androidSettings = AndroidSettings(
      accuracy: LocationAccuracy.best,
      intervalDuration: Duration(milliseconds: 500),
    );
    final iosSettings = AppleSettings(
        accuracy: LocationAccuracy.best, allowBackgroundLocationUpdates: true);
    final settings = Platform.isAndroid ? androidSettings : iosSettings;
    geolocatorStream = Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position position) {
      if (currentPedometerSession == null) {
        currentPedometerSession = PedometerSession(
          sessionId: DateTime.now().toString(),
          sessionTitle: "",
        );
      }
      currentPedometerSession!.speedInMS = position.speed;
      if (currentPedometerSession!.geoPositions == null) {
        currentPedometerSession!.geoPositions = [position];
      }
      currentPedometerSession!.geoPositions!.add(position);

      notifyListeners();
    });
    if (pauseTime != null) {
      currentPedometerSession!.pauseDuration +=
          DateTime.now().difference(pauseTime!);
    }
    notifyListeners();
  }

  void pauseTracking() {
    isTracking = false;
    if (geolocatorStream != null) {
      geolocatorStream!.pause();
      pauseTime = DateTime.now();
    }

    notifyListeners();
  }

  Future<void> stopTracking(
      double speed, double avgSpeed, double maxSpeed, double distance) async {
    isTracking = false;
    if (geolocatorStream != null) {
      var id = DateTime.now().toString();
      currentPedometerSession!.sessionId = id;
      currentPedometerSession!.sessionTitle =
          DateFormat('MM/dd/yy HH:mm').format(DateTime.parse(id)).toString();
      currentPedometerSession!.averageSpeedInMS = avgSpeed;
      currentPedometerSession!.distanceInMeters = distance;
      currentPedometerSession!.endPoint = LatLng(
          currentPedometerSession!.geoPositions!.last.latitude,
          currentPedometerSession!.geoPositions!.last.longitude);
      currentPedometerSession!.startPoint = LatLng(
          currentPedometerSession!.geoPositions!.first.latitude,
          currentPedometerSession!.geoPositions!.first.longitude);
      currentPedometerSession!.startTime =
          currentPedometerSession!.geoPositions!.first.timestamp;
      currentPedometerSession!.endTime =
          currentPedometerSession!.geoPositions!.last.timestamp;
      currentPedometerSession!.pauseDuration =
          currentPedometerSession!.pauseDuration;
      currentPedometerSession!.maxSpeedInMS = maxSpeed;
      currentPedometerSession!.altitude =
          currentPedometerSession!.geoPositions!.last.altitude -
              currentPedometerSession!.geoPositions!.first.altitude;
      currentPedometerSession!.sessionDuration =
          DateTime.now().difference(startTime!) -
              currentPedometerSession!.pauseDuration;
      // currentPedometerSession!.geoPositions!.last.timestamp!.difference(
      //         currentPedometerSession!.geoPositions!.first.timestamp!) -
      //     currentPedometerSession!.pauseDuration;
      currentPedometerSession!.speedInMS = speed;
      currentPedometerSession!.path = Polyline(
        polylineId: PolylineId(id), // Provide a unique ID
        // points: List<LatLng>.from(pathPoints), // Set the path points
        points: currentPedometerSession!.geoPositions!.map((position) {
          return LatLng(position.latitude, position.longitude);
        }).toList(),
        color: Colors.blue, // Set the color of the polyline
        width: 5, // Set the width of the polyline
      );
      currentPedometerSession!.activityType = '';
      currentPedometerSession!.note = '';
      currentPedometerSession!.geoPositions =
          currentPedometerSession!.geoPositions;
      await geolocatorStream!.cancel();
    }
    notifyListeners();
  }
}
