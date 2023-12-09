import 'dart:async';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:location/location.dart' as location;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/app_start_session_provider.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/subscription_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/home/screens/paused_tracking_screen.dart';
import 'package:speedometer/features/home/widgets/carousel_cards.dart';
import 'package:speedometer/features/home/widgets/compass_widget.dart';
import 'package:speedometer/features/home/widgets/speedometer_widget.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:geolocator/geolocator.dart';
import 'package:wakelock/wakelock.dart';

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
    FlutterNativeSplash.remove();
    // checkAndRequestLocationPermission();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (mounted) {
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
        compassSubscription =
            FlutterCompass.events?.listen((CompassEvent event) {
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
                Provider.of<SubscriptionProvider>(context, listen: false)
                    .status;
          },
        );

        if (!Provider.of<PedoMeterSessionProvider>(context, listen: false)
            .isTracking) {
          Future.delayed(
            Duration(seconds: 0),
            () async {
              Provider.of<PedoMeterSessionProvider>(context, listen: false)
                  .startTracking();
            },
          );
        }
        Geolocator.getCurrentPosition().then((value) {
          getCityNameFromCoordinates(value);
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

  Future<String> getCityNameFromCoordinates(Position position) async {
    if (!DebounceService.shouldExecute()) {
      // If the function has been called within the debounce duration, return immediately
      setState(() {
        cityName = DebounceService.cityName;
      });
      return 'Debounced';
    }
    // final url =
    //     'https://nominatim.openstreetmap.org/reverse?lat=33.333057&lon=69.916946&format=json';
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'accept-language': 'en'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('address')) {
          cityName = jsonResponse['address']['city']; // City name
          DebounceService.updateCityName(cityName);

          print("City: $cityName");
        }
      }
      if (cityName == "Unknown" || cityName.isEmpty) {
        print('geocoding was called because api didn\'t responded.');
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (mounted) {
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            var city = placemark.locality; // City name
            print("City:$city");

            setState(() {
              cityName = placemark.locality!;
              if (cityName.isEmpty) {
                cityName = placemark.locality!;
                DebounceService.updateCityName(cityName);
              }
            });
            return city ?? "Unknown";
          } else {
            return "Unknown";
          }
        } else {
          return "Unknown";
        }
      }
      return cityName;
    } catch (e) {
      print("CityNameError: $e");
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (mounted) {
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            var city = placemark.locality; // City name
            print("City:$city");

            setState(() {
              cityName = placemark.locality!;
              DebounceService.updateCityName(cityName);
              // if (cityName.isEmpty) {
              //   cityName = placemark.locality!;
              // }
            });
            return cityName;
          } else {
            return "Unknown";
          }
        } else {
          return "Unknown";
        }
      } catch (e) {
        print("CityNameError:$e");
        // return "Unknown";
      }
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
            maxHeight: width == 414 && height == 896
                ? height * 0.4
                : width == 375 && height == 812
                    ? height * 0.44
                    : width == 375 && height == 667
                        ? height * 0.52
                        : width <= 370 && height >= 820
                            ? height * 0.43
                            : width <= 360 && height >= 700
                                ? height * 0.5
                                : width <= 360 && height <= 700
                                    ? height * 0.57
                                    : width <= 380
                                        ? height * 0.55
                                        : width <= 415 && height <= 740
                                            ? height * 0.5
                                            : width <= 415
                                                ? height * 0.43
                                                : width <= 430
                                                    ? height * 0.47
                                                    : height * 0.57,
            maxWidth: isPortrait
                ? width * 1
                : height <= 420
                    ? height * 1
                    : height * 1.2,
          );
          return Container(
            height: width == 414 && height == 896
                ? height * 0.4
                : width == 375 && height == 812
                    ? height * 0.44
                    : width == 375 && height == 667
                        ? height * 0.52
                        : width <= 370 && height >= 820
                            ? height * 0.43
                            : width <= 360 && height >= 700
                                ? height * 0.5
                                : width <= 360 && height <= 700
                                    ? height * 0.57
                                    : width <= 380
                                        ? height * 0.55
                                        : width <= 415 && height <= 740
                                            ? height * 0.5
                                            : width <= 415
                                                ? height * 0.43
                                                : width <= 430
                                                    ? height * 0.47
                                                    : height * 0.57,
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
                            fontSize: isPortrait
                                ? cityName.characters.length > 15
                                    ? 15.sp
                                    : 18.sp
                                : 8.sp,
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
                    altitude:
                        pedometerSessionProvider.currentPedometerSession !=
                                    null &&
                                pedometerSessionProvider
                                        .currentPedometerSession!
                                        .geoPositions !=
                                    null
                            ? convertDistance(
                                pedometerSessionProvider
                                        .currentPedometerSession!
                                        .geoPositions!
                                        .last
                                        .altitude -
                                    pedometerSessionProvider
                                        .currentPedometerSession!
                                        .geoPositions!
                                        .first
                                        .altitude,
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
          duration: startTime == DateTime(30000)
              ? Duration(seconds: -99)
              : pedometerSessionProvider.currentPedometerSession != null &&
                      pedometerSessionProvider.startTime != null
                  ? DateTime.now()
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
            await Wakelock.disable();

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
            return fancyCards()[index];
          },
        ),
      ),
      floatingActionButtonLocation: isPortrait
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.endTop,
      floatingActionButton: InkWell(
        onTap: () async {
          if (!(pedometerSessionProvider.isTracking) &&
              pedometerSessionProvider.geolocatorStream != null) {
            await pedometerSessionProvider.geolocatorStream!.cancel();
          }
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
            pedometerSessionProvider.isTracking = false;
            await Wakelock.disable();

            pedometerSessionProvider.pauseTracking();
            Navigator.of(context)
                .push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  PausedTrackingScreen(
                      pauseTime: DateTime.now(),
                      avgSpeed: avgSpeed,
                      maxSpeed: maxSpeed,
                      duration: DateTime.now()
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
                await Wakelock.enable();

                Provider.of<RecordingProvider>(context, listen: false)
                    .startRecording();
                pedometerSessionProvider.isTracking = true;
                Provider.of<PedoMeterSessionProvider>(context, listen: false)
                    .startTracking();

                startTracking = true;
                setState(() {});
              } else {
                startingAltitude = 0;
                endingAltitude = 0;
                await Wakelock.disable();

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
                            'Buy the premium version of Speedometer Hero to unlock the full experienceincl. no ads, unlimited activity history & ability to exp data',
                            textAlign: TextAlign.center,
                            style: context.textStyles.mRegular(),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              BuildContext? progressDialogContext;
                              try {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      progressDialogContext = context;
                                      return Center(
                                        child: CupertinoActivityIndicator(
                                            radius: 25),
                                      );
                                    });
                                await Purchases.purchaseProduct(
                                        "1timesubscription")
                                    .then((value) {
                                  Navigator.of(progressDialogContext!).pop();
                                  Provider.of<SubscriptionProvider>(context,
                                          listen: false)
                                      .setSubscriptionStatus(
                                          SubscriptionStatus.subscribed);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Congratulations. You are now a Premium user"),
                                    ),
                                  );
                                });
                              } catch (e) {
                                Navigator.of(progressDialogContext!).pop();

                                print(e.toString());
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Purchase Cancelled",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              Navigator.pop(context);
                            },
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
              await Wakelock.enable();
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
                    ? !pedometerSessionProvider.isTracking
                        ? Colors.white
                        : Color(0xffF82929)
                    : !pedometerSessionProvider.isTracking
                        ? Colors.black
                        : Color(0xffF82929)
                : settings.darkTheme!
                    ? !pedometerSessionProvider.isTracking
                        ? Colors.white
                        : Color(0xffF82929)
                    : !pedometerSessionProvider.isTracking
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
                backgroundColor: pedometerSessionProvider.isTracking
                    ? DateTime.now().second % 2 == 0
                        ? Colors.red
                        : Color(0xffFD8282)
                    : Color(0xffF82929),
                radius: isPortrait ? 18.r : 35.r,
              ),
            )),
      ),
    );
  }
}

class DebounceService {
  static DateTime? _lastExecution;
  static Duration debounceDuration = const Duration(seconds: 5);
  static String cityName = "Unknown"; // Store city name in the debounce service
  static bool shouldExecute() {
    if (_lastExecution != null &&
        DateTime.now().difference(_lastExecution!) < debounceDuration) {
      return false;
    }
    _lastExecution = DateTime.now();
    return true;
  }

  static void updateCityName(String name) {
    cityName = name;
  }
}
