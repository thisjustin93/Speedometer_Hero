import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/components/measurement_box.dart';
import 'package:speedometer/core/providers/pedometer_session.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/app_snackbar.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/services/hive_database_services.dart';

class PausedTrackingScreen extends StatefulWidget {
  final DateTime pauseTime;
  const PausedTrackingScreen({super.key, required this.pauseTime});

  @override
  State<PausedTrackingScreen> createState() => _PausedTrackingScreenState();
}

class _PausedTrackingScreenState extends State<PausedTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    var currentPedometerSession =
        Provider.of<PedoMeterSessionProvider>(context).currentPedometerSession;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.sp, vertical: 5.sp),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 390.h,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/ad.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 15.sp,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MeasurementBox(
                        boxType: 'Max Speed',
                        measurement: convertSpeed(
                            currentPedometerSession!.maxSpeedInMS, 'mph'),
                        measurementUnit: 'mph'),
                    SizedBox(
                      width: 5.sp,
                    ),
                    MeasurementBox(
                        boxType: 'Avg Speed',
                        measurement:
                            currentPedometerSession.distanceInMeters == 0 ||
                                    currentPedometerSession.sessionDuration ==
                                        Duration.zero
                                ? 0
                                : convertSpeed(
                                    currentPedometerSession.distanceInMeters /
                                        currentPedometerSession
                                            .sessionDuration.inSeconds,
                                    'mph'),
                        measurementUnit: 'mph'),
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
                            currentPedometerSession.distanceInMeters, 'mi'),
                        measurementUnit: 'mi'),
                    SizedBox(
                      width: 5.sp,
                    ),
                    MeasurementBox(
                        boxType: 'Duration',
                        measurement: currentPedometerSession
                            .sessionDuration.inSeconds
                            .toDouble(),
                        measurementUnit: 'min'),
                  ],
                ),
                SizedBox(
                  height: 15.sp,
                ),
                Container(
                  height: 85.h,
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
                              await HiveDatabaseServices()
                                  .addSession(currentPedometerSession, context);
                              // showErrorMessage(
                              //     context,
                              //     successSnackbar(
                              //         content: 'Session successfully saved!',
                              //         context: context));

                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 60.h,
                              width: 60.h,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.green),
                              child: Icon(
                                Icons.folder,
                                color: Colors.white,
                                size: 50.sp,
                              ),
                            ),
                          ),
                          Text(
                            'Save',
                            style: AppTextStyles().mRegular,
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
                              height: 60.h,
                              width: 60.h,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.yellow),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 50.sp,
                              ),
                            ),
                          ),
                          Text(
                            'Delete',
                            style: AppTextStyles().mRegular,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 60.h,
                        width: 3.w,
                        child: Container(color: Colors.grey),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () async {
                              currentPedometerSession.pauseDuration +=
                                  DateTime.now().difference(widget.pauseTime);
                              Navigator.of(context).pop(true);
                            },
                            child: CircleAvatar(
                                radius: 30.r,
                                backgroundColor: Colors.black,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 27.r,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 23.r,
                                  ),
                                )),
                          ),
                          Text(
                            'Resume',
                            style: AppTextStyles().mRegular,
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
