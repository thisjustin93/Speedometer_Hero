import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/pedometer_session.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/features/home/screens/paused_tracking_screen.dart';
import 'package:speedometer/core/services/hive_database_services.dart';
import 'package:speedometer/features/home/widgets/carousel_cards.dart';
import 'package:speedometer/features/home/widgets/compass_widget.dart';
import 'package:speedometer/features/home/widgets/speedometer_widget.dart';
import 'package:speedometer/features/settings/screens/settings_page.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double speed = 0;
  double direction = 0;
  double maxSpeed = 0.0;
  StreamSubscription<CompassEvent>? compassSubscription;
  StreamSubscription<Position>? geolocatorStream;
  Position? currentPosition;
  Position? startingPosition;
  double totalDistance = 0; // Total distance covered in meters
  DateTime? startTime;
  DateTime? endTime;
  DateTime? pauseTime;
  bool startTracking = false;
  PedometerSession? pedometerSession;
  List<LatLng> pathPoints = [];


  @override
  void initState() {
    checkAndRequestLocationPermission();
    compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) {
        setState(() {
          direction = event.heading ?? 0;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    compassSubscription?.cancel();
    super.dispose();
  }

  // Request for permissions
  void checkAndRequestLocationPermission() async {
    var status = await permission.Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      await permission.Permission.location.request();
    }
  }

  // Get Device Moving Speed
  void _startTracking() async {
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
      if (mounted) {
        if (position.speed < 0) {
          return;
        } else {
          if (currentPosition != null) {
            double distanceInMeters = Geolocator.distanceBetween(
              currentPosition!.latitude,
              currentPosition!.longitude,
              position.latitude,
              position.longitude,
            );

            totalDistance += distanceInMeters;
          }
          pathPoints.add(LatLng(position.latitude, position.longitude));
          currentPosition = position;
          speed = position.speed;
          if (speed > maxSpeed) {
            maxSpeed = speed;
          }
          startingPosition ??= position;
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var pedometerSessionProvider =
        Provider.of<PedoMeterSessionProvider>(context);
    List<Widget> fancyCards() {
      return <Widget>[
        Card(
          borderOnForeground: false,

          color: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          // elevation: 4.0,
          child: Padding(
            padding: EdgeInsets.all(16.0.sp),
            child: Column(
              children: <Widget>[
                Container(
                  width: 250.w,
                  height: 200.h,
                  color: Colors.transparent,
                ),
                Text(
                  '',
                ),
                OutlinedButton(
                  child: const Text(""),
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      side: BorderSide.none),
                ),
              ],
            ),
          ),
        ),
        FancyCard(
          cardIndex: 0,
          speed: convertSpeed(speed, 'mph'), //Use "ft/s", "km/h", or "mph"
          maxSpeed: convertSpeed(maxSpeed, 'mph'),
          duration: startTime != null
              ? endTime != null
                  ? endTime!.difference(startTime!)
                  : pedometerSessionProvider.currentPedometerSession != null
                      ? DateTime.now().difference(startTime!) -
                          pedometerSessionProvider
                              .currentPedometerSession!.pauseDuration
                      : DateTime.now().difference(startTime!)
              : Duration.zero,
          distanceCovered: convertDistance(totalDistance, 'mi'),
          onPressed: () {
            geolocatorStream?.cancel();
            geolocatorStream = null;
            speed = 0;
            maxSpeed = 0;
            totalDistance = 0;
            startTime = null;
            endTime = null;
            startTracking = false;
            pauseTime = null;
            setState(() {});
          },
        ),
        FancyCard(
          cardIndex: 1,
          googleMapAPI: 'assets/images/map.png',
        ),
        SizedBox(
          height: 60.h,
        )
      ];
    }

    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Positioned(
              top: (MediaQuery.of(context).padding.top + 45).h,
              left: 0,
              right: 0,
              child: Text(
                'Jerico',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 15.h,
              child: CompassWidget(
                direction: direction,
              ),
            ),
            Positioned(
              top: 15.h,
              left: 0,
              right: 0,
              child: SpeedometerWidget(
                speed: speed,
              ),
            ),
            ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: fancyCards().length,
              itemBuilder: (context, index) {
                return fancyCards()[index];
              },
            )
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: () async {
          if (startTracking && !(geolocatorStream!.isPaused)) {
            String sessionId = DateTime.now().toString();
            startTracking = false;
            endTime = DateTime.now();
            pauseTime = DateTime.now();
            // geolocatorStream?.cancel();
            geolocatorStream?.pause();
            pedometerSessionProvider.setCurrentPedometerSession(
              PedometerSession(
                sessionId: sessionId,
                averageSpeedInMS:
                    totalDistance / endTime!.difference(startTime!).inSeconds,
                distanceInMeters: totalDistance,
                endPoint: LatLng(
                    currentPosition!.latitude, currentPosition!.longitude),
                startPoint: LatLng(
                    startingPosition!.latitude, startingPosition!.longitude),
                startTime: startTime,
                endTime: endTime,
                pauseDuration:
                    pedometerSessionProvider.currentPedometerSession == null
                        ? Duration.zero
                        : pedometerSessionProvider
                            .currentPedometerSession!.pauseDuration,
                maxSpeedInMS: maxSpeed,
                sessionDuration:
                    pedometerSessionProvider.currentPedometerSession == null
                        ? endTime!.difference(startTime!)
                        : endTime!.difference(startTime!) -
                            pedometerSessionProvider
                                .currentPedometerSession!.pauseDuration,
                speedInMS: speed,
                path: Polyline(
                  polylineId: PolylineId(sessionId), // Provide a unique ID
                  points: pathPoints, // Set the path points
                  color: Colors.blue, // Set the color of the polyline
                  width: 5, // Set the width of the polyline
                ),
              ),
            );

            Navigator.of(context)
                .push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  PausedTrackingScreen(pauseTime: DateTime.now()),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                var begin = Offset(1.0, 0.0);
                var end = Offset.zero;
                var curve = Curves.ease;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ))
                .then((value) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    titlePadding: EdgeInsets.only(top: 10.h),
                    contentPadding: EdgeInsets.zero,
                    insetPadding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 200.h),
                    title: Container(
                      alignment: Alignment.center,
                      height: 50.sp,
                      width: 50.sp,
                      decoration: BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                    ),
                    content: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Column(
                        children: [
                          Text(
                            'Buy the premium version of Speedometer GPSto unlock the full experienceincl. no ads, unlimited activity history & ability to exp data',
                            textAlign: TextAlign.center,
                            style: AppTextStyles().mRegular,
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                fixedSize: Size(300.w, 40.h),
                                shape: StadiumBorder()),
                            child: Text(
                              'Unlimited Activity History',
                              style: AppTextStyles().mThick,
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Cancel",
                                style: AppTextStyles().mRegular,
                              ))
                        ],
                      ),
                    ),
                  );
                },
              );
              bool? isContinue = value;
              if (isContinue != null && isContinue) {
                endTime = null;
                pauseTime = null;
                startTracking = true;
                _startTracking();

                setState(() {});
              }
            });
            // _stopTracking();
          } else {
            // if (geolocatorStream == null || !(geolocatorStream!.isPaused)) {
            startTime = DateTime.now();
            speed = 0;
            maxSpeed = 0;
            totalDistance = 0;
            currentPosition = null;
            pauseTime = null;
            // }
            // startTime = pauseTime != null
            //     ? startTime!.add(DateTime.now().difference(pauseTime!))
            //     : startTime;
            pauseTime = null;
            startTracking = true;
            endTime = null;
            _startTracking();
          }
          setState(() {});
        },
        child: CircleAvatar(
            radius: 24.r,
            backgroundColor: startTime == null ||
                    geolocatorStream != null && !(geolocatorStream!.isPaused)
                ? Colors.red
                : Colors.black,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 21.r,
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 18.r,
              ),
            )),
      ),
    );
  }
}
