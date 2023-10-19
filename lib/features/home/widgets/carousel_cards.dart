import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/components/measurement_box.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/home/widgets/duration_counter.dart';

class FancyCard extends StatelessWidget {
  FancyCard(
      {super.key,
      required this.cardIndex,
      this.speed = 0,
      this.avgSpeed = 0,
      this.distanceCovered = 0,
      this.maxSpeed = 0,
      this.duration = Duration.zero,
      this.googleMapAPI = '',
      this.onPressed});
  String googleMapAPI = '';
  int cardIndex;
  double speed = 0;
  double maxSpeed = 0;
  double avgSpeed = 0;

  double distanceCovered = 0;
  var duration = Duration.zero;
  VoidCallback? onPressed = () {};

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<UnitsProvider>(context).settings;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return googleMapAPI.isEmpty
        ? Card(
            color: Theme.of(context).colorScheme.background,
            borderOnForeground: false,
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Container(
              color: Theme.of(context).colorScheme.background,
              height: isPortrait ? 300.h : 230.h,
              width: isPortrait
                  ? 320.w
                  : (MediaQuery.of(context).size.width * 0.49),
              padding: isPortrait
                  ? EdgeInsets.symmetric(horizontal: 25.w)
                  : EdgeInsets.only(
                      top: (MediaQuery.of(context).size.height * 0.22).h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: settings.darkTheme
                              ? Color(0xff1c1c1e)
                              : Color(0xffc6c6c6),
                          width: isPortrait ? 2.sp : 1.sp),
                    ),
                    // width: isPortrait ? null : 170.w,
                    height: isPortrait ? 140.h : 280.h,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 35.w,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: isPortrait ? 12.sp : 0.sp,
                            ),
                            Text(
                              settings.speedUnit == 'mph'
                                  ? 'MPH'
                                  : settings.speedUnit == 'kmph'
                                      ? "KMPH"
                                      : "M/S",
                              style: context.textStyles.mRegular().copyWith(
                                  fontSize: isPortrait ? null : 10.sp),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              speed.toStringAsFixed(0),
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: isPortrait ? 100.sp : 50.sp,
                                  height: 0.7),
                            )
                          ],
                        ),
                        IconButton(
                            alignment: Alignment.center,
                            constraints: BoxConstraints(
                                maxHeight: 35.sp, maxWidth: 35.sp),
                            icon: Transform.flip(
                              flipX: true,
                              child: Transform.rotate(
                                angle: -0.4,
                                child: Icon(
                                  Icons.replay,
                                  size: isPortrait ? 30.sp : 20.sp,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            onPressed: onPressed
                            // size: 35.sp,
                            )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: isPortrait ? 4.sp : 2.sp,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MeasurementBox(
                          boxType: 'Max Speed',
                          measurement: maxSpeed,
                          measurementUnit: settings.speedUnit == "mph"
                              ? 'MPH'
                              : settings.speedUnit == 'kmph'
                                  ? 'KM/H'
                                  : 'M/S'),
                      MeasurementBox(
                          boxType: 'Avg Speed',
                          measurement:
                              convertSpeed(avgSpeed, settings.speedUnit),
                          // measurement: distanceCovered == 0 ||
                          //         duration == Duration.zero
                          //     ? 0
                          //     : distanceCovered /
                          //         (duration.inSeconds /
                          //             (settings.speedUnit == 'mps' ? 1 : 3600)),
                          measurementUnit: settings.speedUnit == "mph"
                              ? 'MPH'
                              : settings.speedUnit == 'kmph'
                                  ? 'KM/H'
                                  : 'M/S'),
                    ],
                  ),
                  SizedBox(
                    height: isPortrait ? 4.sp : 2.sp,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MeasurementBox(
                          boxType: 'Distance',
                          measurement: distanceCovered,
                          measurementUnit: settings.speedUnit == "mph"
                              ? 'Mi'
                              : settings.speedUnit == 'kmph'
                                  ? 'KM'
                                  : 'M'),
                      MeasurementBox(
                          boxType: 'Duration',
                          measurement: duration.inSeconds.toDouble(),
                          measurementUnit: ''),
                    ],
                  ),
                ],
              ),
            ),
          )
        : Card(
            margin: isPortrait
                ? EdgeInsets.only(top: 10.h)
                : EdgeInsets.only(
                    top: (MediaQuery.of(context).size.height * 0.23).h,
                    bottom: (MediaQuery.of(context).size.height * 0.15).h,
                    right: 5.w),

            // elevation: 6.0,
            child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isPortrait ? 15.w : 0.w,
                ),
                height: 260.h,
                width: isPortrait ? 320.w : 180.w,
                child: Image.asset(
                  googleMapAPI,
                  fit: BoxFit.cover,
                )),
          );
  }
}
