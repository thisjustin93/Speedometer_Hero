import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geocoding/geocoding.dart';
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
  String cityName = "Unknown";
  // var pedometerSessionProvider;
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
    // currentPosition = null;
    pauseTime = null;
    endTime = null;
    startingAltitude = 0;
    endingAltitude = 0;
    // _startTracking();
    compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) {
        setState(() {
          direction = event.heading ?? 0;
        });
      }
    });
    Future.delayed(
      Duration(milliseconds: 100),
      () {
        subscriptionStatus =
            Provider.of<SubscriptionProvider>(context, listen: false).status;
      },
    );
    if (!Provider.of<PedoMeterSessionProvider>(context, listen: false)
        .isTracking) {
      Future.delayed(
        Duration(seconds: 0),
        () async {
          // await
          // getPermissions();
          Provider.of<PedoMeterSessionProvider>(context, listen: false)
              .startTracking();
        },
      );
    }

    // pedometerSessionProvider = Provider.of<PedoMeterSessionProvider>(context);
    // setState(() {});
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

// getPermissions
  getPermissions() async {
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
  }

  // Get Device Moving Speed
  // void _startTracking() async {
  //   geolocatorStream = null;
  //   var status = await Geolocator.checkPermission();

  //   if (status == LocationPermission.denied ||
  //       status == LocationPermission.deniedForever ||
  //       status == LocationPermission.unableToDetermine) {
  //     await Geolocator.requestPermission();
  //   }

  //   bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

  //   if (!isLocationServiceEnabled) {
  //     final result = await location.Location().requestService();
  //     if (result == true) {
  //       print('Service has been enabled');
  //     } else {
  //       print('Service has not been enabled');
  //     }
  //   }

  //   final geolocator = Geolocator();

  //   // List<LatLng> points = []
  //   final androidSettings = AndroidSettings(
  //     accuracy: LocationAccuracy.best,
  //     intervalDuration: Duration(seconds: 1),
  //   );
  //   final iosSettings = AppleSettings(
  //       accuracy: LocationAccuracy.best, allowBackgroundLocationUpdates: true);
  //   final settings = Platform.isAndroid ? androidSettings : iosSettings;
  //   startTime = DateTime.now();
  //   speed = 0;
  //   maxSpeed = 0;
  //   totalDistance = 0;
  //   // currentPosition = null;
  //   pauseTime = null;
  //   endTime = null;
  //   startingAltitude = 0;
  //   endingAltitude = 0;
  //   geolocatorStream = Geolocator.getPositionStream(locationSettings: settings)
  //       .listen((Position position) {
  //     if (mounted) {
  //       geoPostions.add(position);
  //       // if (position.speed < 0) {
  //       //   return;
  //       // } else {
  //       if (currentPosition != null) {
  //         double distanceInMeters = Geolocator.distanceBetween(
  //           currentPosition!.latitude,
  //           currentPosition!.longitude,
  //           position.latitude,
  //           position.longitude,
  //         );

  //         totalDistance += distanceInMeters;
  //       }
  //       if (startingAltitude == 0) {
  //         startingAltitude = position.altitude;
  //       }
  //       endingAltitude = position.altitude;
  //       pathPoints.add(LatLng(position.latitude, position.longitude));
  //       currentPosition = position;

  //       speed = position.speed;
  //       if (speed > maxSpeed) {
  //         maxSpeed = speed;
  //       }
  //       startingPosition ??= position;
  //       if (DateTime.now().difference(startTime!).inSeconds % 3 == 0) {
  //         getCityNameFromCoordinates(position);
  //       }
  //       // }
  //       avgSpeed = 0;
  //       for (var i in geoPostions) {
  //         avgSpeed = (avgSpeed + i.speed);
  //       }
  //       avgSpeed /= geoPostions.length;

  //       setState(() {});
  //     }
  //   });
  // }

  Future<String> getCityNameFromCoordinates(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (mounted) {
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final city = placemark.locality; // City name
          setState(() {
            cityName = placemark.locality!;
          });
          return city ?? "Unknown";
        } else {
          return "Unknown";
        }
      } else {
        return "Unknown";
      }
    } catch (e) {
      print(e);
      return "Unknown";
    }
  }

// Assign Data from provider to the variables. It's so that all calculations are in one place rather
// calculating everything when assigning it.
  void setDataFromProvider(PedometerSession session) async {
    // assign current speed
    speed = session.speedInMS;
    // assign current max speed
    for (int i = 1; i < session.geoPositions!.length; i++) {
      double speed = session.geoPositions![i].speed;
      if (speed > maxSpeed) {
        maxSpeed = speed;
      }
    }
    // assign current average speed
    double totalSpeed = 0;
    for (int i = 0; i < session.geoPositions!.length; i++) {
      totalSpeed += session.geoPositions![i].speed;
    }

    avgSpeed = totalSpeed / session.geoPositions!.length;
    // assign total distance
    totalDistance = 0;
    for (int i = 1; i < session.geoPositions!.length; i++) {
      double distanceInMeters = Geolocator.distanceBetween(
        session.geoPositions![i - 1].latitude,
        session.geoPositions![i - 1].longitude,
        session.geoPositions![i].latitude,
        session.geoPositions![i].longitude,
      );
      totalDistance += distanceInMeters;
    }
    // assign city name
    await getCityNameFromCoordinates(session.geoPositions!.last);
    // assign start and end time
    startTime = session.geoPositions!.first.timestamp;
    endTime = session.geoPositions!.last.timestamp;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    print(MediaQuery.sizeOf(context));
    var pedometerSessionProvider =
        Provider.of<PedoMeterSessionProvider>(context);
    if (pedometerSessionProvider.currentPedometerSession != null) {
      setDataFromProvider(pedometerSessionProvider.currentPedometerSession!);
    }
    var settings = Provider.of<UnitsProvider>(context).settings;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    List<Widget> fancyCards() {
      return <Widget>[
        LayoutBuilder(builder: (context, constraints) {
          constraints = BoxConstraints(
            //  width <= 380
            //   ? 1
            //   : width > 380 && width <= 415
            //       ? 1.15
            //       : width > 415 && width <= 445
            //           ? 1.2
            //           : width > 445 && width <= 490
            //               ? 1.35

            // maxHeight: height < 730 ? height * 0.55 : height * 0.43,
            maxHeight: width <= 380
                ? height * 0.55
                : width <= 430
                    ? height * 0.47
                    : height * 0.55,
            maxWidth: isPortrait
                ? width * 1
                : height <= 420
                    ? height * 1
                    : height * 1.2,
          );
          return Container(
            height: width <= 380
                ? height * 0.55
                : width <= 430
                    ? height * 0.47
                    : height * 0.55,
            width: isPortrait
                ? width * 1
                : height <= 420
                    ? height * 1
                    : height * 1.2,
            // padding: EdgeInsets.only(top: 10.h),
            child: Stack(
              children: [
                if (settings.showCityName)
                  Positioned(
                    top: isPortrait
                        ? (constraints.maxHeight * 0.22)
                        : (constraints.maxHeight * 0.38),
                    left: 0,
                    right: 0,
                    bottom: isPortrait ? null : 0,
                    child: Text(
                      cityName,
                      style: context.textStyles.mRegular().copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isPortrait ? 18.sp : 8.sp,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (settings.showCompass)
                  Positioned(
                    // top: isPortrait ? height * 0.035 : height * 0.05,
                    top: isPortrait
                        ? width < 420
                            ? height * 0.035
                            : height * 0.08
                        : height * 0.05,
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
                  top: isPortrait
                      ? width < 420
                          ? height * 0.035
                          : height * 0.08
                      : height * 0.05,
                  left: 0,
                  right: 0,
                  bottom: isPortrait ? null : 0,
                  child: SpeedometerWidget(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    speed: convertSpeed(speed, settings.speedUnit),
                    altitude: geoPostions.isNotEmpty
                        ? convertDistance(
                            geoPostions.last.altitude -
                                geoPostions.first.altitude,
                            settings.elevationUnit)
                        : 0,
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(
          height: 10.h,
          width: isPortrait ? 0 : 5.w,
        ),
        FancyCard(
          cardIndex: 0,
          speed: speed == -99
              ? '--'
              : convertSpeed(speed, settings.speedUnit).toStringAsFixed(0),
          maxSpeed: maxSpeed == -99
              ? '--'
              : convertSpeed(maxSpeed, settings.speedUnit).toStringAsFixed(1),
          // duration: startTime == DateTime(30000)
          //     ? Duration(seconds: -99)
          //     : startTime != null
          //         ? pedometerSessionProvider.currentPedometerSession != null
          //             ? endTime!
          //                 .subtract(pedometerSessionProvider
          //                     .currentPedometerSession!.pauseDuration)
          //                 .difference(startTime!)
          //             : DateTime.now().difference(startTime!)
          //         : Duration.zero,
          duration: startTime == DateTime(30000)
              ? Duration(seconds: -99)
              : pedometerSessionProvider.currentPedometerSession != null &&
                      pedometerSessionProvider.startTime != null
                  ?
                  // endTime != null
                  //     ? endTime!
                  //         .subtract(pedometerSessionProvider
                  //             .currentPedometerSession!.pauseDuration)
                  //         .difference(startTime!)
                  //     :
                  DateTime.now()
                      .subtract(pedometerSessionProvider
                          .currentPedometerSession!.pauseDuration)
                      .difference(pedometerSessionProvider.startTime!)
                  : Duration.zero,
          distanceCovered: totalDistance == -99
              ? '--'
              : convertDistance(
                      totalDistance,
                      settings.speedUnit == 'mph'
                          ? 'mi'
                          : settings.speedUnit == 'kmph'
                              ? 'km'
                              : settings.speedUnit == 'knots'
                                  ? "knots"
                                  : 'm')
                  .toStringAsFixed(1),
          avgSpeed: avgSpeed == -99
              ? '--'
              : convertSpeed(avgSpeed, settings.speedUnit).toStringAsFixed(1),
          onPressed: () async {
            // geolocatorStream?.pause();
            pedometerSessionProvider.isTracking = false;
            await pedometerSessionProvider.geolocatorStream!.cancel();
            // currentPosition = await Geolocator.getCurrentPosition();
            if (pedometerSessionProvider.currentPedometerSession != null &&
                pedometerSessionProvider
                        .currentPedometerSession!.geoPositions !=
                    null) {
              currentPosition = pedometerSessionProvider
                  .currentPedometerSession!.geoPositions!.first;
              setState(() {});
            }

            Provider.of<PedoMeterSessionProvider>(context, listen: false)
                .currentPedometerSession = null;
            Provider.of<PedoMeterSessionProvider>(context, listen: false)
                .startTime = null;
            Provider.of<PedoMeterSessionProvider>(context, listen: false)
                .pauseTime = null;
            Provider.of<RecordingProvider>(context, listen: false)
                .stopRecording();
            endTime = null;
            startTracking = false;
            pauseTime = null;
            pathPoints.clear();
            // currentPosition = null;
            geolocatorStream != null ? geolocatorStream!.pause() : null;
            startTime = DateTime(30000);
            // startTime = null;
            speed = -99;
            avgSpeed = -99;
            maxSpeed = -99;
            totalDistance = -99;
            geoPostions.removeRange(0, geoPostions.length);
            await Future.delayed(Duration(seconds: 1));
            speed = 0;
            maxSpeed = 0;
            startTime = null;
            avgSpeed = 0;

            totalDistance = 0;
            if (mounted) {
              setState(() {});
            }
          },
        ),
        SizedBox(
          height: 10.h,
          width: isPortrait ? 0 : 5,
        ),
        // if (pedometerSessionProvider.currentPedometerSession != null)
        FancyCard(
          speed: speed == -99
              ? '--'
              : convertSpeed(speed, settings.speedUnit).toStringAsFixed(0),
          cardIndex: 1,
          googleMapAPI: 'assets/images/map.png',
          position: pedometerSessionProvider.currentPedometerSession != null
              ? pedometerSessionProvider
                  .currentPedometerSession!.geoPositions!.last
              : currentPosition,
          polyline: Polyline(
            polylineId: PolylineId(
                pedometerSessionProvider.currentPedometerSession != null
                    ? pedometerSessionProvider
                        .currentPedometerSession!.sessionId
                    : ''),
            points: pedometerSessionProvider.currentPedometerSession != null
                ? pedometerSessionProvider.isTracking
                    ? pedometerSessionProvider
                        .currentPedometerSession!.geoPositions!
                        .map((position) {
                        return LatLng(position.latitude, position.longitude);
                      }).toList()
                    : []
                : [],
            color: Colors.blue,
            width: 5,
          ),
        ),
        SizedBox(
          height: 10.h,
          width: isPortrait ? 0 : 5,
        ),
      ];
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: isPortrait ? Axis.vertical : Axis.horizontal,
          physics: BouncingScrollPhysics(),
          itemCount: fancyCards().length,
          itemBuilder: (context, index) {
            return
                // index == 2
                //     ? isPortrait
                //         ? GestureDetector(
                //             onVerticalDragUpdate: (detail) {},
                //             child: fancyCards()[index],
                //           )
                //         : GestureDetector(
                //             onHorizontalDragUpdate: (detail) {},
                //             child: fancyCards()[index],
                //           )
                //     :
                fancyCards()[index];
          },
        ),
      ),
      floatingActionButtonLocation: isPortrait
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.endTop,
      floatingActionButton: InkWell(
        onTap: () async {
          if (pedometerSessionProvider.currentPedometerSession != null &&
              pedometerSessionProvider.currentPedometerSession!.geoPositions !=
                  null) {
            currentPosition = pedometerSessionProvider
                .currentPedometerSession!.geoPositions!.first;
            setState(() {});
          }

          if (Provider.of<RecordingProvider>(context, listen: false)
              .recordingStarted) {
            Provider.of<RecordingProvider>(context, listen: false)
                .stopRecording();
          } else {
            Provider.of<RecordingProvider>(context, listen: false)
                .startRecording();
          }

          if (pedometerSessionProvider.geolocatorStream != null &&
              !(pedometerSessionProvider.geolocatorStream!.isPaused) &&
              pedometerSessionProvider.isTracking) {
            // currentPosition = await Geolocator.getCurrentPosition();

            pedometerSessionProvider.isTracking = false;
            pedometerSessionProvider.pauseTracking();
            Navigator.of(context)
                .push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  PausedTrackingScreen(
                      pauseTime: DateTime.now(),
                      avgSpeed: avgSpeed,
                      maxSpeed: maxSpeed,
                      duration: DateTime.now()!
                          .subtract(pedometerSessionProvider
                              .currentPedometerSession!.pauseDuration)
                          .difference(pedometerSessionProvider.startTime!),
                      distance: totalDistance),
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
                .then((value) async {
              // Checks for when we return from Pause Screen
              bool? isContinue = value;
              if (isContinue != null && isContinue) {
                Provider.of<RecordingProvider>(context, listen: false)
                    .startRecording();
                pedometerSessionProvider.isTracking = true;
                Provider.of<PedoMeterSessionProvider>(context, listen: false)
                    .startTracking();
                // endTime = null;
                // pauseTime = null;
                startTracking = true;
                // _startTracking();
                // geolocatorStream!.resume();
                setState(() {});
              } else {
                startingAltitude = 0;
                endingAltitude = 0;
                await pedometerSessionProvider.geolocatorStream!.cancel();
                pedometerSessionProvider.isTracking = false;
                pedometerSessionProvider.startTime = null;
                pedometerSessionProvider.currentPedometerSession = null;
                pedometerSessionProvider.pauseTime = null;

                startTime = null;
                endTime = null;
                startingPosition = null;
                totalDistance = 0;
                avgSpeed = 0;
                speed = 0;
                maxSpeed = 0;
                // pathPoints.clear();
                // currentPosition = null;
                pauseTime = null;
                startTracking = false;
                setState(() {});
              }
            });
          } else {
            // to start tracking but if not subscribed then show a dialog to subscribe
            if (pedometerSessionProvider.pedometerSessions.length >= 8 &&
                subscriptionStatus == SubscriptionStatus.notSubscribed) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r)),
                    titlePadding: EdgeInsets.only(top: 10.h),
                    contentPadding: EdgeInsets.zero,
                    insetPadding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 215.h),
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
                              style: context.textStyles
                                  .mThick()
                                  .copyWith(color: Colors.white),
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
            }
            // When Subscribed, the start recording
            else {
              // maxSpeed = 0;
              // totalDistance = 0;
              // currentPosition = null;

              pauseTime = null;
              startTracking = true;
              endTime = null;
              pathPoints.clear();

              startingAltitude = 0;
              endingAltitude = 0;
              // -99 is a code speed to show the speed as -- for a second. Per clients request
              geolocatorStream != null ? geolocatorStream!.pause() : null;
              Provider.of<PedoMeterSessionProvider>(context, listen: false)
                  .currentPedometerSession = null;
              Provider.of<PedoMeterSessionProvider>(context, listen: false)
                  .startTime = null;
              Provider.of<PedoMeterSessionProvider>(context, listen: false)
                  .pauseTime = null;
              startTime = DateTime(30000);
              setState(() {});
              // startTime = null;
              speed = -99;
              avgSpeed = -99;
              maxSpeed = -99;
              totalDistance = -99;
              await Future.delayed(Duration(seconds: 1));
              startTime = DateTime.now();
              speed = 0;
              maxSpeed = 0;
              avgSpeed = 0;
              totalDistance = 0;
              // currentPosition = null;
              Provider.of<PedoMeterSessionProvider>(context, listen: false)
                  .isTracking = true;
              Provider.of<PedoMeterSessionProvider>(context, listen: false)
                  .startTracking();

              // _startTracking();
            }
          }
          setState(() {});
        },
        child: CircleAvatar(
            radius: isPortrait ? 24.r : 45.r,
            backgroundColor: settings.darkTheme == null
                ? MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? !startTracking
                        ? Colors.white
                        : Color(0xffF82929)
                    : !startTracking
                        ? Colors.black
                        : Color(0xffF82929)
                : settings.darkTheme!
                    ? !startTracking
                        ? Colors.white
                        : Color(0xffF82929)
                    : !startTracking
                        ? Colors.black
                        : Color(0xffF82929),
            child: CircleAvatar(
              backgroundColor: settings.darkTheme == null
                  ? MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Colors.black
                      : Colors.white
                  : settings.darkTheme!
                      ? Colors.black
                      : Colors.white,
              radius: isPortrait ? 21.r : 40.r,
              child: CircleAvatar(
                backgroundColor: startTracking
                    ? DateTime.now().second % 2 == 0
                        ? Colors.red
                        : Color(0xffFD8282)
                    : Color(0xffF82929),
                radius: isPortrait ? 18.r : 35.r,
              ),
            )),
      ),

      // floatingActionButton: InkWell(
      //   onTap: () async {
      //     if (Provider.of<RecordingProvider>(context, listen: false)
      //         .recordingStarted) {
      //       Provider.of<RecordingProvider>(context, listen: false)
      //           .stopRecording();
      //     } else {
      //       Provider.of<RecordingProvider>(context, listen: false)
      //           .startRecording();
      //     }

      //     if (startTracking && !(geolocatorStream!.isPaused)) {
      //       String sessionId = DateTime.now().toString();
      //       startTracking = false;
      //       endTime = DateTime.now();
      //       pauseTime = DateTime.now();
      //       // geolocatorStream?.cancel();
      //       geolocatorStream?.pause();
      //       pedometerSessionProvider.setCurrentPedometerSession(
      //         PedometerSession(
      //           sessionId: DateTime.now().toString(),
      //           sessionTitle: DateFormat('MM/dd/yy HH:mm')
      //               .format(DateTime.parse(sessionId))
      //               .toString(),
      //           averageSpeedInMS:
      //               totalDistance / endTime!.difference(startTime!).inSeconds,
      //           distanceInMeters: totalDistance,
      //           endPoint: LatLng(
      //               currentPosition!.latitude, currentPosition!.longitude),
      //           startPoint: LatLng(
      //               startingPosition!.latitude, startingPosition!.longitude),
      //           startTime: startTime,
      //           endTime: endTime,
      //           pauseDuration:
      //               pedometerSessionProvider.currentPedometerSession == null
      //                   ? Duration.zero
      //                   : pedometerSessionProvider
      //                       .currentPedometerSession!.pauseDuration,
      //           maxSpeedInMS: maxSpeed,
      //           altitude: endingAltitude - startingAltitude,
      //           sessionDuration:
      //               pedometerSessionProvider.currentPedometerSession == null
      //                   ? endTime!.difference(startTime!)
      //                   : endTime!.difference(startTime!) -
      //                       pedometerSessionProvider
      //                           .currentPedometerSession!.pauseDuration,
      //           speedInMS: speed,
      //           path: Polyline(
      //             polylineId: PolylineId(sessionId), // Provide a unique ID
      //             // points: List<LatLng>.from(pathPoints), // Set the path points
      //             points: pathPoints,
      //             color: Colors.blue, // Set the color of the polyline
      //             width: 5, // Set the width of the polyline
      //           ),
      //           activityType: '',
      //           note: '',
      //           geoPositions: geoPostions,
      //         ),
      //       );
      //       Navigator.of(context)
      //           .push(PageRouteBuilder(
      //         pageBuilder: (context, animation, secondaryAnimation) =>
      //             PausedTrackingScreen(pauseTime: DateTime.now()),
      //         transitionsBuilder:
      //             (context, animation, secondaryAnimation, child) {
      //           var begin = Offset(1.0, 0.0);
      //           var end = Offset.zero;
      //           var curve = Curves.ease;
      //           var tween = Tween(begin: begin, end: end)
      //               .chain(CurveTween(curve: curve));

      //           return SlideTransition(
      //             position: animation.drive(tween),
      //             child: child,
      //           );
      //         },
      //       ))
      //           .then((value) {
      //         // Checks for when we return from Pause Screen
      //         bool? isContinue = value;
      //         if (isContinue != null && isContinue) {
      //           Provider.of<RecordingProvider>(context, listen: false)
      //               .startRecording();
      //           endTime = null;
      //           pauseTime = null;
      //           startTracking = true;
      //           // _startTracking();
      //           geolocatorStream!.resume();
      //           setState(() {});
      //         } else {
      //           startingAltitude = 0;
      //           endingAltitude = 0;
      //           pedometerSessionProvider.currentPedometerSession = null;
      //           startTime = null;
      //           endTime = null;
      //           startingPosition = null;
      //           totalDistance = 0;
      //           avgSpeed = 0;
      //           speed = 0;
      //           maxSpeed = 0;
      //           // pathPoints.clear();
      //           // currentPosition = null;
      //           pauseTime = null;
      //           startTracking = false;
      //           setState(() {});
      //         }
      //       });
      //     } else {
      //       // to start tracking but if not subscribed then show a dialog to subscribe
      //       if (pedometerSessionProvider.pedometerSessions.length >= 8 &&
      //           subscriptionStatus == SubscriptionStatus.notSubscribed) {
      //         showDialog(
      //           context: context,
      //           builder: (context) {
      //             return AlertDialog(
      //               backgroundColor: Theme.of(context).colorScheme.primary,
      //               shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(5.r)),
      //               titlePadding: EdgeInsets.only(top: 10.h),
      //               contentPadding: EdgeInsets.zero,
      //               insetPadding:
      //                   EdgeInsets.symmetric(horizontal: 10.w, vertical: 215.h),
      //               title: Container(
      //                 alignment: Alignment.center,
      //                 height: 50.sp,
      //                 width: 50.sp,
      //                 decoration: BoxDecoration(
      //                     color: Color(0xffF82929), shape: BoxShape.circle),
      //                 child: Icon(
      //                   Icons.shopping_cart,
      //                   color: Colors.white,
      //                   size: 30.sp,
      //                 ),
      //               ),
      //               content: Container(
      //                 padding: EdgeInsets.symmetric(horizontal: 10.w),
      //                 child: Column(
      //                   children: [
      //                     Text(
      //                       'Buy the premium version of Speedometer GPSto unlock the full experienceincl. no ads, unlimited activity history & ability to exp data',
      //                       textAlign: TextAlign.center,
      //                       style: context.textStyles.mRegular(),
      //                     ),
      //                     SizedBox(
      //                       height: 10.h,
      //                     ),
      //                     ElevatedButton(
      //                       onPressed: () {},
      //                       style: ElevatedButton.styleFrom(
      //                           backgroundColor: Color(0xffF82929),
      //                           foregroundColor: Colors.white,
      //                           fixedSize: Size(300.w, 40.h),
      //                           shape: StadiumBorder()),
      //                       child: Text(
      //                         'Unlimited Activity History',
      //                         style: context.textStyles
      //                             .mThick()
      //                             .copyWith(color: Colors.white),
      //                       ),
      //                     ),
      //                     TextButton(
      //                         onPressed: () {
      //                           Navigator.of(context).pop();
      //                         },
      //                         child: Text(
      //                           "Cancel",
      //                           style: context.textStyles.mRegular(),
      //                         ))
      //                   ],
      //                 ),
      //               ),
      //             );
      //           },
      //         );
      //       }
      //       // When Subscribed, the start recording
      //       else {
      //         // maxSpeed = 0;
      //         // totalDistance = 0;
      //         // currentPosition = null;
      //         pauseTime = null;
      //         startTracking = true;
      //         endTime = null;
      //         pathPoints.clear();

      //         startingAltitude = 0;
      //         endingAltitude = 0;
      //         // -99 is a code speed to show the speed as -- for a second. Per clients request
      //         geolocatorStream != null ? geolocatorStream!.pause() : null;
      //         startTime = DateTime(30000);
      //         // startTime = null;
      //         speed = -99;
      //         avgSpeed = -99;
      //         maxSpeed = -99;
      //         totalDistance = -99;
      //         await Future.delayed(Duration(seconds: 1));
      //         _startTracking();
      //       }
      //     }
      //     setState(() {});
      //   },
      //   child: CircleAvatar(
      //       radius: isPortrait ? 24.r : 45.r,
      //       backgroundColor: settings.darkTheme == null
      //           ? MediaQuery.of(context).platformBrightness == Brightness.dark
      //               ? !startTracking
      //                   ? Colors.white
      //                   : Color(0xffF82929)
      //               : !startTracking
      //                   ? Colors.black
      //                   : Color(0xffF82929)
      //           : settings.darkTheme!
      //               ? !startTracking
      //                   ? Colors.white
      //                   : Color(0xffF82929)
      //               : !startTracking
      //                   ? Colors.black
      //                   : Color(0xffF82929),
      //       child: CircleAvatar(
      //         backgroundColor: settings.darkTheme == null
      //             ? MediaQuery.of(context).platformBrightness == Brightness.dark
      //                 ? Colors.black
      //                 : Colors.white
      //             : settings.darkTheme!
      //                 ? Colors.black
      //                 : Colors.white,
      //         radius: isPortrait ? 21.r : 40.r,
      //         child: CircleAvatar(
      //           backgroundColor: startTracking
      //               ? DateTime.now().second % 2 == 0
      //                   ? Colors.red
      //                   : Color(0xffFD8282)
      //               : Color(0xffF82929),
      //           radius: isPortrait ? 18.r : 35.r,
      //         ),
      //       )),
      // ),
    );
  }
}
