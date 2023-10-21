import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/services/hive_database_services.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/history/screens/session_details_screen.dart';
import 'package:speedometer/features/history/widgets/matching_activity_tiles.dart';
import 'package:speedometer/features/history/widgets/sessionActivity.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:speedometer/features/history/widgets/edit_bottomsheet.dart';
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
  bool selectSessions = false;
  // List<int> selectedSessionsIndex = [];
  assignData() {
    final pedometerProvider =
        Provider.of<PedoMeterSessionProvider>(context, listen: false);
    final pedometerSessions = pedometerProvider.pedometerSessions;
    if (pedometerSessions.isNotEmpty) {
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
    } else {
      topMaxSpeedList = [];
      topAvgSpeedList = [];
      topDistanceList = [];
      topDurationList = [];
      topMaxSpeedSession = null;
      topAvgSpeedSession = null;
      topDistanceSession = null;
      topDurationSession = null;
    }
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
    var settings = Provider.of<UnitsProvider>(context).settings;
    matchingActivity = [
      {
        'activityType': 'Top Max Speed',
        'icon': Icons.local_fire_department,
        'session': topMaxSpeedSession,
        'valueUnit': settings.speedUnit
      },
      {
        'activityType': 'Top Avg Speed',
        'icon': Icons.speed,
        'session': topAvgSpeedSession,
        'valueUnit': settings.speedUnit
      },
      {
        'activityType': 'Top Distance',
        'icon': Icons.straighten,
        'session': topDistanceSession,
        'valueUnit': settings.speedUnit == 'mph'
            ? 'miles'
            : settings.speedUnit == 'kmph'
                ? 'kilometers'
                : "meters"
      },
      {
        'activityType': 'Top Duration',
        'icon': Icons.watch_later_outlined,
        'session': topDurationSession,
        'valueUnit': 'minutes'
      },
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        toolbarHeight: 40.h,
        actions: [
          InkWell(
            onTap: () {
              setState(() {
                selectSessions = false;
              });
            },
            onLongPress: () {
              setState(() {
                selectSessions = true;
              });
            },
            child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle),
                width: 70.w,
                alignment: Alignment.center,
                child: Text(
                  selectSessions ? "Done" : "Select",
                  style: context.textStyles.mRegular().copyWith(
                      color: selectSessions
                          ? Colors.red
                          : Theme.of(context).colorScheme.onPrimary),
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
                style: context.textStyles.lMedium(),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(left: 15.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                      color: settings.darkTheme
                          ? Color(0xff1c1c1e)
                          : Color(0xffc6c6c6),
                      width: 2.sp),
                ),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (matchingActivity[index]['session'] == null) {
                          return;
                        }
                        Navigator.of(context)
                            .push(PageRouteBuilder(
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
                        ))
                            .then((value) {
                          assignData();
                          setState(() {});
                        });
                      },
                      child: MatchingActivityTile(
                        activityType: matchingActivity[index]['activityType'],
                        icon: matchingActivity[index]['icon'],
                        tileIndex: index,
                        tilesLength: matchingActivity.length,
                        session: matchingActivity[index]['session'] ??
                            PedometerSession(
                                sessionId: 'null',
                                sessionTitle: 'null',
                                speedInMS: 0,
                                maxSpeedInMS: 0,
                                averageSpeedInMS: 0,
                                distanceInMeters: 0,
                                sessionDuration: Duration.zero),
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
                  color: Theme.of(context).primaryColor,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(8.r)),
                  border: Border.all(
                      color: settings.darkTheme
                          ? Color(0xff1c1c1e)
                          : Color(0xffc6c6c6),
                      width: 2.sp),
                ),
                child: pedometerSessionProvider.pedometerSessions.isEmpty
                    ? Center(
                        child: Text(
                          "No Session Saved yet.",
                          style: context.textStyles.mRegular(),
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
                                    editBottomSheet(
                                      context,
                                      pedometerSessionProvider
                                          .pedometerSessions[index],
                                      () {},
                                    );
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
                                    shareBottomSheet(
                                        context,
                                        pedometerSessionProvider
                                            .pedometerSessions[index]);
                                  },
                                  backgroundColor: Color(0xFF00BF63),
                                  foregroundColor: Colors.white,
                                  icon: Icons.file_upload_outlined,
                                  padding: EdgeInsets.all(5.sp),

                                  // label: 'Save',
                                ),
                                SlidableAction(
                                  onPressed: (context) async {
                                    await HiveDatabaseServices().deleteSession(
                                        pedometerSessionProvider
                                            .pedometerSessions[index]
                                            .sessionId);

                                    List<PedometerSession> sessions =
                                        await HiveDatabaseServices()
                                            .getAllSessions();

                                    Provider.of<PedoMeterSessionProvider>(
                                            context,
                                            listen: false)
                                        .updatePedometerSessionList(sessions);

                                    setState(() {});
                                  },
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
                                Navigator.of(context)
                                    .push(PageRouteBuilder(
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
                                ))
                                    .then((value) {
                                  assignData();
                                  setState(() {});
                                });
                              },
                              child: SessionActivityTile(
                                  pedometerSession: pedometerSessionProvider
                                      .pedometerSessions[index],
                                  tileIndex: index,
                                  tilesLength: matchingActivity.length,
                                  showCheckBox: selectSessions,
                                  deleteSession: () async {
                                    await HiveDatabaseServices().deleteSession(
                                        pedometerSessionProvider
                                            .pedometerSessions[index]
                                            .sessionId);

                                    List<PedometerSession> sessions =
                                        await HiveDatabaseServices()
                                            .getAllSessions();
                                    Provider.of<PedoMeterSessionProvider>(
                                            context,
                                            listen: false)
                                        .updatePedometerSessionList(sessions);
                                    assignData();
                                    setState(() {});
                                  }
                                  // selectedSessions: selectedSessionsIndex,
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
