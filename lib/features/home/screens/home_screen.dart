import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as location;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/app_start_session_provider.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/subscription_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/services/ad_mob_service.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/home/screens/paused_tracking_screen.dart';
import 'package:speedometer/features/home/widgets/carousel_cards.dart';
import 'package:speedometer/features/home/widgets/compass_widget.dart';
import 'package:speedometer/features/home/widgets/speedometer_widget.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double speed = 0;
  double avgSpeed = 0;
  double direction = 0;
  double maxSpeed = 0.0;
  double startingAltitude = 0;
  double endingAltitude = 0;
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
  SubscriptionStatus? subscriptionStatus;
  List<Position> geoPostions = [];

  @override
  void initState() {
    Future.delayed(
      Duration(milliseconds: 1000),
      () {
        FlutterNativeSplash.remove();
      },
    );
    // checkAndRequestLocationPermission();
    startTime = DateTime.now();
    speed = 0;
    maxSpeed = 0;
    totalDistance = 0;
    currentPosition = null;
    pauseTime = null;
    endTime = null;
    startingAltitude = 0;
    endingAltitude = 0;
    _startTracking();
    compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) {
        setState(() {
          direction = event.heading ?? 0;
        });
      }
    });
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        subscriptionStatus =
            Provider.of<SubscriptionProvider>(context, listen: false).status;
      },
    );
    Provider.of<PedoMeterSessionProvider>(context, listen: false)
        .currentPedometerSession = null;

    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    compassSubscription?.cancel();
    super.dispose();
  }

  // Request for permissions
  Future checkAndRequestLocationPermission() async {
    var status = await permission.Permission.location.status;
    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      await permission.Permission.location.request();
    }
  }

  // Get Device Moving Speed
  void _startTracking() async {
    geolocatorStream = null;
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
        geoPostions.add(position);
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
          if (startingAltitude == 0) {
            startingAltitude = position.altitude;
          }
          endingAltitude = position.altitude;
          pathPoints.add(LatLng(position.latitude, position.longitude));
          currentPosition = position;

          speed = position.speed;
          if (speed > maxSpeed) {
            maxSpeed = speed;
          }
          startingPosition ??= position;
        }
        avgSpeed = 0;
        for (var i in geoPostions) {
          avgSpeed = (avgSpeed + i.speed) / geoPostions.length;
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    var pedometerSessionProvider =
        Provider.of<PedoMeterSessionProvider>(context);

    var settings = Provider.of<UnitsProvider>(context).settings;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    List<Widget> fancyCards() {
      return <Widget>[
        LayoutBuilder(builder: (context, constraints) {
          constraints = BoxConstraints(
            maxHeight: height * 0.7,
            maxWidth: width * 1,
            // maxHeight: isPortrait ? constraints.maxHeight : 480,
            // maxWidth: isPortrait ? constraints.maxWidth : 672,
          );
          return Container(
            height: height * 0.47,
            width: isPortrait ? width * 1 : width * 0.48,
            child: Stack(
              children: [
                if (settings.showCityName)
                  Positioned(
                    top: isPortrait
                        ? (constraints.maxHeight * 0.15)
                        : (constraints.maxHeight * 0.28),
                    left: 0,
                    // left: isPortrait ? 0 : (constraints.maxWidth * 0.21),
                    right: 0,
                    // right: isPortrait ? 0 : null,
                    bottom: isPortrait ? null : 0,
                    child: Text(
                      'Jerico',
                      style: context.textStyles.mRegular().copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isPortrait ? 18.sp : 10.sp,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (settings.showCompass)
                  Positioned(
                    top: isPortrait ? height * 0.02 : 0,
                    left: 0,
                    right: 0,
                    bottom: isPortrait ? null : 0,
                    child: SafeArea(
                      child: CompassWidget(
                        direction: direction,
                      ),
                    ),
                  ),
                Positioned(
                  top: isPortrait ? height * 0.02 : height * 0.05,
                  left: 0,
                  right: 0,
                  bottom: isPortrait ? null : 0,
                  child: SpeedometerWidget(
                    altitude: convertDistance(endingAltitude - startingAltitude,
                        settings.elevationUnit),
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(
          height: 10.h,
        ),
        FancyCard(
          cardIndex: 0,
          speed: convertSpeed(speed, settings.speedUnit),
          maxSpeed: convertSpeed(maxSpeed, settings.speedUnit),
          duration: startTime != null
              ? endTime != null
                  ? endTime!.difference(startTime!)
                  : pedometerSessionProvider.currentPedometerSession != null
                      ? DateTime.now()
                          .subtract(pedometerSessionProvider
                              .currentPedometerSession!.pauseDuration)
                          .difference(startTime!)
                      : DateTime.now().difference(startTime!)
              : Duration.zero,
          distanceCovered: convertDistance(
              totalDistance,
              settings.speedUnit == 'mph'
                  ? 'mi'
                  : settings.speedUnit == 'kmph'
                      ? 'km'
                      : 'm'),
          avgSpeed: avgSpeed,
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
        // SizedBox(
        //   height: 100.h,
        // )
      ];
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ListView.builder(
        shrinkWrap: true,
        scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: fancyCards().length,
        itemBuilder: (context, index) {
          return fancyCards()[index];
        },
      ),
      floatingActionButtonLocation: isPortrait
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.endTop,
      floatingActionButton: InkWell(
        onTap: () async {
          Provider.of<AppStartProvider>(context, listen: false).changeState();

          if (startTracking && !(geolocatorStream!.isPaused)) {
            String sessionId = DateTime.now().toString();
            startTracking = false;
            endTime = DateTime.now();
            pauseTime = DateTime.now();
            // geolocatorStream?.cancel();
            geolocatorStream?.pause();
            pedometerSessionProvider.setCurrentPedometerSession(
              PedometerSession(
                sessionId: DateTime.now().toString(),
                sessionTitle: DateFormat('MM/dd/yy HH:mm')
                    .format(DateTime.parse(sessionId))
                    .toString(),
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
                altitude: endingAltitude - startingAltitude,
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
                activityType: '',
                note: '',
                geoPositions: geoPostions,
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
              bool? isContinue = value;
              if (isContinue != null && isContinue) {
                endTime = null;
                pauseTime = null;
                startTracking = true;
                _startTracking();

                setState(() {});
              } else {
                startingAltitude = 0;
                endingAltitude = 0;
                pedometerSessionProvider.currentPedometerSession = null;
                startTime = null;
                endTime = null;
                startingPosition = null;
                totalDistance = 0;
                speed = 0;
                maxSpeed = 0;
                currentPosition = null;
                pauseTime = null;
                startTracking = false;
                setState(() {});
              }
            });
          } else {
            if (pedometerSessionProvider.pedometerSessions.length >= 4 &&
                subscriptionStatus == SubscriptionStatus.notSubscribed) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Color.fromARGB(247, 211, 211, 204),
                    titlePadding: EdgeInsets.only(top: 10.h),
                    contentPadding: EdgeInsets.zero,
                    insetPadding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 200.h),
                    title: Container(
                      alignment: Alignment.center,
                      height: 50.sp,
                      width: 50.sp,
                      decoration: BoxDecoration(
                          color: Color(0xffF82929), shape: BoxShape.circle),
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
                            style: context.textStyles.mRegular(),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xffF82929),
                                foregroundColor: Colors.white,
                                fixedSize: Size(300.w, 40.h),
                                shape: StadiumBorder()),
                            child: Text(
                              'Unlimited Activity History',
                              style: context.textStyles.mThick(),
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "Cancel",
                                style: context.textStyles.mRegular(),
                              ))
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              startTime = DateTime.now();
              speed = 0;
              maxSpeed = 0;
              totalDistance = 0;
              currentPosition = null;
              pauseTime = null;
              startTracking = true;
              endTime = null;
              _startTracking();
            }
          }
          setState(() {});
        },
        child: CircleAvatar(
            radius: isPortrait ? 24.r : 45.r,
            backgroundColor: settings.darkTheme
                ? Colors.white
                : startTime != null && !startTracking
                    ? Colors.black
                    : Color(0xffF82929),
            child: CircleAvatar(
              backgroundColor: settings.darkTheme ? Colors.black : Colors.white,
              radius: isPortrait ? 21.r : 40.r,
              child: CircleAvatar(
                backgroundColor:
                    startTracking ? Color(0xffFD8282) : Color(0xffF82929),
                radius: isPortrait ? 18.r : 35.r,
              ),
            )),
      ),
    );
  }
}
