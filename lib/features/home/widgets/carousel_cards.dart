import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/components/measurement_box.dart';
import 'package:speedometer/core/providers/pedometer_session.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
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
    return googleMapAPI.isEmpty
        ? Card(
            color: Color(0xFFEBEBE3),
            borderOnForeground: false,
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Container(
              color: Color(0xFFEBEBE3),
              height: 310.h,
              width: 320.w,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      // color: Color.fromARGB(111, 238, 238, 255),
                      // color: Color(0xfff6f6f6),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          // color: Color.fromARGB(117, 222, 222, 255),
                          // color: Color(0xffc6c6c6),
                          color: Colors.white,
                          width: 2.sp),
                    ),
                    height: 140.h,
                    // width: 320.w,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 35.w,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: PaddingSizes.sm,
                            ),
                            Text(
                              'MPH',
                              style: AppTextStyles().mRegular,
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              speed.toStringAsFixed(0),
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 110.sp,
                                  height: 0.8),
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
                                  size: 30.sp,
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
                    height: PaddingSizes.xxs.sp,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MeasurementBox(
                          boxType: 'Max Speed',
                          measurement: maxSpeed,
                          measurementUnit: 'MPH'),
                      MeasurementBox(
                          boxType: 'Avg Speed',
                          measurement: distanceCovered == 0 ||
                                  duration == Duration.zero
                              ? 0
                              : convertSpeed(
                                  distanceCovered / duration.inSeconds, 'mph'),
                          measurementUnit: 'MPH'),
                    ],
                  ),
                  SizedBox(
                    height: PaddingSizes.xxs.sp,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MeasurementBox(
                          boxType: 'Distance',
                          measurement: distanceCovered,
                          measurementUnit: 'Mi'),
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
            margin: EdgeInsets.zero,

            // elevation: 6.0,
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                height: 300.h,
                width: 320.w,
                child: Image.asset(
                  googleMapAPI,
                  fit: BoxFit.cover,
                )),
          );
  }
}
