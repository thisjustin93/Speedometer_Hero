import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/components/measurement_box.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
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
  const PausedTrackingScreen({super.key, required this.pauseTime});

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
    AdSize adSize = AdSize(width: screenWidth.toInt(), height: 390);
    _banner = BannerAd(
        size: adSize,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerAdListener,
        request: const AdRequest())
      ..load();
  }

  @override
  void didChangeDependencies() {
    _createBannerAd(MediaQuery.of(context).size.width);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var currentPedometerSessionProvider =
        Provider.of<PedoMeterSessionProvider>(context);
    var settings = Provider.of<UnitsProvider>(context).settings;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.sp, vertical: 5.sp),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 390.h,
                  color: Theme.of(context).colorScheme.background,
                  padding: EdgeInsets.symmetric(horizontal: 5.sp),
                  width: double.infinity,
                  child: AdWidget(ad: _banner!),
                ),
                SizedBox(
                  height: isPortrait ? 15.sp : 5.sp,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MeasurementBox(
                        boxType: 'Max Speed',
                        measurement: convertSpeed(
                            currentPedometerSessionProvider
                                .currentPedometerSession!.maxSpeedInMS,
                            settings.speedUnit),
                        measurementUnit: settings.speedUnit),
                    SizedBox(
                      width: 5.sp,
                    ),
                    MeasurementBox(
                        boxType: 'Avg Speed',
                        measurement: currentPedometerSessionProvider
                                        .currentPedometerSession!
                                        .distanceInMeters ==
                                    0 ||
                                currentPedometerSessionProvider
                                        .currentPedometerSession!
                                        .sessionDuration ==
                                    Duration.zero
                            ? 0
                            : convertSpeed(
                                currentPedometerSessionProvider
                                        .currentPedometerSession!
                                        .distanceInMeters /
                                    currentPedometerSessionProvider
                                        .currentPedometerSession!
                                        .sessionDuration
                                        .inSeconds,
                                settings.speedUnit),
                        measurementUnit: settings.speedUnit),
                  ],
                ),
                SizedBox(
                  height: 5.sp,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MeasurementBox(
                        boxType: 'Distance',
                        measurement: convertDistance(
                            currentPedometerSessionProvider
                                .currentPedometerSession!.distanceInMeters,
                            settings.speedUnit == "mph"
                                ? 'mi'
                                : settings.speedUnit == 'kmph'
                                    ? 'km'
                                    : 'm'),
                        measurementUnit: settings.speedUnit == "mph"
                            ? 'mi'
                            : settings.speedUnit == 'kmph'
                                ? 'km'
                                : 'm'),
                    SizedBox(
                      width: 5.sp,
                    ),
                    MeasurementBox(
                        boxType: 'Duration',
                        measurement: currentPedometerSessionProvider
                            .currentPedometerSession!.sessionDuration.inSeconds
                            .toDouble(),
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
                            onTap: () {
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
                      SizedBox(
                        height: isPortrait ? 50.h : 160.h,
                        width: isPortrait ? 3.w : 2.w,
                        child: Container(color: Colors.grey),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              currentPedometerSessionProvider
                                      .currentPedometerSession!.pauseDuration +=
                                  DateTime.now().difference(widget.pauseTime);
                              Navigator.of(context).pop(true);
                            },
                            child: CircleAvatar(
                                radius: isPortrait ? 30.r : 55.r,
                                backgroundColor: settings.darkTheme
                                    ? Colors.white
                                    : Colors.black,
                                child: CircleAvatar(
                                  backgroundColor: settings.darkTheme
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
