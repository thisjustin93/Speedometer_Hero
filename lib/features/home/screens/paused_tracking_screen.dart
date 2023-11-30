import 'dart:io';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/components/measurement_box.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/subscription_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/services/ad_mob_service.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/app_snackbar.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/services/hive_database_services.dart';
import 'package:speedometer/core/utils/extensions/context.dart';

class PausedTrackingScreen extends StatefulWidget {
  final DateTime pauseTime;
  double maxSpeed;
  double avgSpeed;
  double distance;
  Duration duration;

  PausedTrackingScreen(
      {super.key,
      required this.pauseTime,
      required this.avgSpeed,
      required this.distance,
      required this.duration,
      required this.maxSpeed});

  @override
  State<PausedTrackingScreen> createState() => _PausedTrackingScreenState();
}

class _PausedTrackingScreenState extends State<PausedTrackingScreen> {
  //   InterstitialAd? _interstitialAd;
  // void _createInterstitialAd() {
  //   InterstitialAd.load(
  //       adUnitId: AdMobService.instertitialAdUnitId!,
  //       request: const AdRequest(),
  //       adLoadCallback: InterstitialAdLoadCallback(
  //         onAdLoaded: (ad) => _interstitialAd = ad,
  //         onAdFailedToLoad: (error) => _interstitialAd = null,
  //       ));
  // }
  BannerAd? _banner;
  void _createBannerAd(double screenWidth) {
    AdSize adSize = AdSize(width: screenWidth.toInt(), height: 390.h.toInt());
    _banner = BannerAd(
        size: adSize,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerAdListener,
        request: const AdRequest())
      ..load();
  }

  @override
  void didChangeDependencies() {
    Provider.of<SubscriptionProvider>(context, listen: false).status ==
            SubscriptionStatus.notSubscribed
        ? _createBannerAd(MediaQuery.of(context).size.width)
        : null;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var currentPedometerSessionProvider =
        Provider.of<PedoMeterSessionProvider>(context);
    var settings = Provider.of<UnitsProvider>(context).settings;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    bool isUserSubscribed =
        Provider.of<SubscriptionProvider>(context, listen: true).status ==
            SubscriptionStatus.subscribed;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.sp, vertical: 5.sp),
          child: SingleChildScrollView(
            child: Column(
              children: [
                !isUserSubscribed ||
                        currentPedometerSessionProvider
                                .currentPedometerSession ==
                            null ||
                        Platform.isAndroid
                    ? Container(
                        height: 340.h,
                        color: Theme.of(context).colorScheme.background,
                        padding: EdgeInsets.symmetric(horizontal: 5.sp),
                        width: double.infinity,
                        child: _banner == null ? null : AdWidget(ad: _banner!),
                      )
                    : Container(
                        height: 340.h,
                        color: Theme.of(context).colorScheme.background,
                        padding: EdgeInsets.symmetric(horizontal: 5.sp),
                        width: double.maxFinite,
                        child: AppleMap(
                          initialCameraPosition: CameraPosition(
                              target: LatLng(
                                currentPedometerSessionProvider
                                    .currentPedometerSession!
                                    .geoPositions!
                                    .first
                                    .latitude,
                                currentPedometerSessionProvider
                                    .currentPedometerSession!
                                    .geoPositions!
                                    .first
                                    .longitude,
                              ),
                              zoom: 25),
                          zoomGesturesEnabled: true,
                          gestureRecognizers:
                              <Factory<OneSequenceGestureRecognizer>>[
                            new Factory<OneSequenceGestureRecognizer>(
                              () => new EagerGestureRecognizer(),
                            ),
                          ].toSet(),
                          mapType: MapType.standard,
                          scrollGesturesEnabled: true,
                          annotations: Set()
                            ..add(
                              Annotation(
                                  annotationId: AnnotationId('start'),
                                  position: LatLng(
                                    currentPedometerSessionProvider
                                        .currentPedometerSession!
                                        .geoPositions!
                                        .first
                                        .latitude,
                                    currentPedometerSessionProvider
                                        .currentPedometerSession!
                                        .geoPositions!
                                        .first
                                        .longitude,
                                  ),
                                  icon: BitmapDescriptor.markerAnnotation),
                            )
                            ..add(
                              Annotation(
                                  annotationId: AnnotationId('end'),
                                  position: LatLng(
                                    currentPedometerSessionProvider
                                        .currentPedometerSession!
                                        .geoPositions!
                                        .last
                                        .latitude,
                                    currentPedometerSessionProvider
                                        .currentPedometerSession!
                                        .geoPositions!
                                        .last
                                        .longitude,
                                  ),
                                  icon: BitmapDescriptor.markerAnnotation),
                            ),
                          polylines: Set<Polyline>.of([
                            Polyline(
                              polylineId: PolylineId(
                                  currentPedometerSessionProvider
                                              .currentPedometerSession !=
                                          null
                                      ? currentPedometerSessionProvider
                                          .currentPedometerSession!.sessionId
                                      : ''),
                              color: Colors.blue,
                              points: List<LatLng>.from(
                                currentPedometerSessionProvider
                                    .currentPedometerSession!.geoPositions!
                                    .map((position) {
                                      return LatLng(position.latitude,
                                          position.longitude);
                                    })
                                    .toList()
                                    .map(
                                      (e) => LatLng(e.latitude, e.longitude),
                                    ),
                              ),
                              width: 5,
                            ),
                          ]),
                        ),
                      ),
                SizedBox(
                  height: isPortrait ? 15.sp : 5.sp,
                ),
                if (currentPedometerSessionProvider.currentPedometerSession !=
                    null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MeasurementBox(
                          boxType: 'Max Speed',
                          measurement:
                              convertSpeed(widget.maxSpeed, settings.speedUnit)
                                  .toStringAsFixed(1),
                          measurementUnit: settings.speedUnit),
                      SizedBox(
                        width: 5.sp,
                      ),
                      MeasurementBox(
                          boxType: 'Avg Speed',
                          measurement:
                              convertSpeed(widget.avgSpeed, settings.speedUnit)
                                  .toStringAsFixed(1),
                          measurementUnit: settings.speedUnit),
                    ],
                  ),
                SizedBox(
                  height: 5.sp,
                ),
                if (currentPedometerSessionProvider.currentPedometerSession !=
                    null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MeasurementBox(
                          boxType: 'Distance',
                          measurement: convertDistance(
                                  widget.distance,
                                  settings.speedUnit == "mph"
                                      ? 'mi'
                                      : settings.speedUnit == 'kmph'
                                          ? 'km'
                                          : settings.speedUnit == 'knots'
                                              ? "knots"
                                              : 'm')
                              .toStringAsFixed(1),
                          measurementUnit: settings.speedUnit == "mph"
                              ? 'mi'
                              : settings.speedUnit == 'kmph'
                                  ? 'km'
                                  : settings.speedUnit == 'knots'
                                      ? "knots"
                                      : 'm'),
                      SizedBox(
                        width: 5.sp,
                      ),
                      MeasurementBox(
                          boxType: 'Duration',
                          measurement: widget.duration.inSeconds.toString(),
                          measurementUnit: 'min'),
                    ],
                  ),
                SizedBox(
                  height: isPortrait ? 15.sp : 5.sp,
                ),
                Container(
                  height: isPortrait ? 85.h : 180.h,
                  padding: EdgeInsets.symmetric(horizontal: 13.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              currentPedometerSessionProvider.stopTracking(
                                  currentPedometerSessionProvider
                                      .currentPedometerSession!
                                      .geoPositions!
                                      .first
                                      .speed,
                                  widget.avgSpeed,
                                  widget.maxSpeed,
                                  widget.distance);
                              await HiveDatabaseServices().addSession(
                                  currentPedometerSessionProvider
                                      .currentPedometerSession!,
                                  context);
                              currentPedometerSessionProvider.pedometerSessions
                                  .add(currentPedometerSessionProvider
                                      .currentPedometerSession!);
                              currentPedometerSessionProvider
                                  .updatePedometerSessionList(
                                      currentPedometerSessionProvider
                                          .pedometerSessions);
                              await currentPedometerSessionProvider
                                  .geolocatorStream!
                                  .cancel();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: isPortrait ? 60.h : 110.h,
                              width: isPortrait ? 60.h : 120.h,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.green),
                              child: Icon(
                                Icons.folder,
                                color: Colors.white,
                                size: isPortrait ? 50.sp : 25.sp,
                              ),
                            ),
                          ),
                          Text(
                            'Save',
                            style: context.textStyles.sRegular(),
                          )
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              await currentPedometerSessionProvider
                                  .geolocatorStream!
                                  .cancel();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: isPortrait ? 60.h : 110.h,
                              width: isPortrait ? 60.h : 120.h,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.yellow),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: isPortrait ? 50.sp : 25.sp,
                              ),
                            ),
                          ),
                          Text(
                            'Delete',
                            style: context.textStyles.sRegular(),
                          )
                        ],
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 6.h),
                          height: isPortrait ? 50.h : 160.h,
                          width: isPortrait ? 3.w : 2.w,
                          color: Colors.grey),
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () async {
                                // currentPedometerSessionProvider
                                //         .currentPedometerSession!
                                //         .pauseDuration +=
                                //     DateTime.now().difference(widget.pauseTime);
                                await currentPedometerSessionProvider
                                    .geolocatorStream!
                                    .cancel();
                                Navigator.of(context).pop(true);
                              },
                              child: CircleAvatar(
                                  radius: isPortrait ? 30.r : 55.r,
                                  backgroundColor: settings.darkTheme == null
                                      ? MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black
                                      : settings.darkTheme!
                                          ? Colors.white
                                          : Colors.black,
                                  child: CircleAvatar(
                                    backgroundColor: settings.darkTheme == null
                                        ? MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.black
                                            : Colors.white
                                        : settings.darkTheme!
                                            ? Colors.black
                                            : Colors.white,
                                    radius: isPortrait ? 27.r : 51.r,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: isPortrait ? 23.r : 43.r,
                                    ),
                                  )),
                            ),
                            Text(
                              'Resume',
                              style: context.textStyles.sRegular(),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
