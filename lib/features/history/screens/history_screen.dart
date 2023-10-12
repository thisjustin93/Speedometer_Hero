// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/pedometer_session.dart';
import 'package:speedometer/core/services/hive_database_services.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/features/history/screens/session_details_screen.dart';
import 'package:speedometer/features/history/widgets/matching_activity_tiles.dart';
import 'package:speedometer/features/history/widgets/sessionActivity.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:speedometer/features/history/widgets/share_bottomsheet.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<double> topMaxSpeedList = [];
  List<double> topAvgSpeedList = [];
  List<double> topDistanceList = [];
  List<double> topDurationList = [];
  PedometerSession? topMaxSpeedSession;
  PedometerSession? topAvgSpeedSession;
  PedometerSession? topDistanceSession;
  PedometerSession? topDurationSession;
  List matchingActivity = [];
  assignData() {
    final pedometerProvider =
        Provider.of<PedoMeterSessionProvider>(context, listen: false);
    final pedometerSessions = pedometerProvider.pedometerSessions;
    topMaxSpeedSession = pedometerSessions[0];
    topAvgSpeedSession = pedometerSessions[0];
    topDistanceSession = pedometerSessions[0];
    topDurationSession = pedometerSessions[0];
    for (var pedometerSession in pedometerSessions) {
      if (topMaxSpeedSession!.maxSpeedInMS < pedometerSession.maxSpeedInMS) {
        topMaxSpeedSession = pedometerSession;
      }
      if (topDistanceSession!.distanceInMeters <
          pedometerSession.distanceInMeters) {
        topDistanceSession = pedometerSession;
      }
      if (topDurationSession!.sessionDuration <
          pedometerSession.sessionDuration) {
        topDurationSession = pedometerSession;
      }
      if (topAvgSpeedSession!.averageSpeedInMS <
          pedometerSession.averageSpeedInMS) {
        topAvgSpeedSession = pedometerSession;
      }
    }
    matchingActivity = [
      {
        'activityType': 'Top Max Speed',
        'icon': Icons.local_fire_department,
        'session': topMaxSpeedSession,
        'valueUnit': 'mph'
      },
      {
        'activityType': 'Top Avg Speed',
        'icon': Icons.speed,
        'session': topAvgSpeedSession,
        'valueUnit': 'mph'
      },
      {
        'activityType': 'Top Distance',
        'icon': Icons.straighten,
        'session': topDistanceSession,
        'valueUnit': 'miles'
      },
      {
        'activityType': 'Top Duration',
        'icon': Icons.watch_later_outlined,
        'session': topDurationSession,
        'valueUnit': 'minutes'
      },
    ];
  }

  @override
  void initState() {
    assignData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var pedometerSessionProvider =
        Provider.of<PedoMeterSessionProvider>(context);
    return Scaffold(
      backgroundColor: Color(0xFFEBEBE3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        toolbarHeight: 40.h,
        actions: [
          InkWell(
            onLongPress: () {},
            child: Container(
                width: 60.w,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select",
                  style: AppTextStyles().mRegular.copyWith(color: Colors.black),
                )),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "History",
                style: AppTextStyles().lMedium,
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(left: 15.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.white, width: 2.sp),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: matchingActivity.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                              SessionDetailsScreen(
                                  session: matchingActivity[index]['session']),
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
                        ));
                      },
                      child: MatchingActivityTile(
                        activityType: matchingActivity[index]['activityType'],
                        icon: matchingActivity[index]['icon'],
                        tileIndex: index,
                        tilesLength: matchingActivity.length,
                        session: matchingActivity[index]['session'],
                        valueUnit: matchingActivity[index]['valueUnit'],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              Container(
                height: 280.h,
                width: double.maxFinite,
                padding: EdgeInsets.only(left: 15.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(8.r)),
                  border: Border.all(color: Colors.white, width: 2.sp),
                ),
                child: pedometerSessionProvider.pedometerSessions.isEmpty
                    ? Center(
                        child: Text(
                          "No Session Saved yet.",
                          style: AppTextStyles().mRegular,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount:
                            pedometerSessionProvider.pedometerSessions.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            key: ValueKey(0),
                            endActionPane: ActionPane(
                              motion: DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    // await HiveDatabaseServices().updateSession(index, updatedSession)
                                  },
                                  backgroundColor: Color(0xFFC6C6C6),
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit_note,
                                  padding: EdgeInsets.all(5.sp),
                                ),
                                SlidableAction(
                                  onPressed: (context) {
                                    // Dialog when click share button
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              backgroundColor: Color.fromARGB(
                                                  247, 211, 211, 204),
                                              titlePadding:
                                                  EdgeInsets.only(top: 10.h),
                                              contentPadding: EdgeInsets.zero,
                                              insetPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 10.w,
                                                      vertical: 200.h),
                                              title: Container(
                                                alignment: Alignment.center,
                                                height: 50.sp,
                                                width: 50.sp,
                                                decoration: BoxDecoration(
                                                    color: Color(0xffF82929),
                                                    shape: BoxShape.circle),
                                                child: Icon(
                                                  Icons.shopping_cart,
                                                  color: Colors.white,
                                                  size: 30.sp,
                                                ),
                                              ),
                                              content: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'Buy the premium version of Speedometer GPSto unlock the full experienceincl. no ads, unlimited activity history & ability to exp data',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: AppTextStyles()
                                                          .mRegular,
                                                    ),
                                                    SizedBox(
                                                      height: 10.h,
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        final directory =
                                                            await getApplicationDocumentsDirectory();
                                                        final file = File(
                                                            '${directory.path}/abc.txt');
                                                        await file.writeAsString(
                                                            jsonEncode(
                                                                pedometerSessionProvider
                                                                    .pedometerSessions[
                                                                        index]
                                                                    .toMap()));
                                                        Navigator.of(context)
                                                            .pop();
                                                        //Bottom sheet when click export data
                                                        Share.shareXFiles(
                                                            [XFile(file.path)]);
                                                        // shareBottomSheet(
                                                        //     context,
                                                        //     pedometerSessionProvider
                                                        //             .pedometerSessions[
                                                        //         index],
                                                        //     file);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Color(
                                                                      0xffF82929),
                                                              foregroundColor:
                                                                  Colors.white,
                                                              fixedSize: Size(
                                                                  300.w, 40.h),
                                                              shape:
                                                                  StadiumBorder()),
                                                      child: Text(
                                                        'Export Data',
                                                        style: AppTextStyles()
                                                            .mThick,
                                                      ),
                                                    ),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          "Cancel",
                                                          style: AppTextStyles()
                                                              .mRegular
                                                              .copyWith(
                                                                  color: Colors
                                                                      .black),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            ));
                                  },
                                  backgroundColor: Color(0xFF00BF63),
                                  foregroundColor: Colors.white,
                                  icon: Icons.file_upload_outlined,
                                  padding: EdgeInsets.all(5.sp),

                                  // label: 'Save',
                                ),
                                SlidableAction(
                                  onPressed: (context) {},
                                  backgroundColor: Color(0xFFFF0000),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_outline,
                                  padding: EdgeInsets.all(5.sp),

                                  // label: 'Save',
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      SessionDetailsScreen(
                                          session: pedometerSessionProvider
                                              .pedometerSessions[index]),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
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
                                ));
                              },
                              child: SessionActivityTile(
                                pedometerSession: pedometerSessionProvider
                                    .pedometerSessions[index],
                                tileIndex: index,
                                tilesLength: matchingActivity.length,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
