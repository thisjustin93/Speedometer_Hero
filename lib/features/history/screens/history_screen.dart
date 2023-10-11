import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/providers/pedometer_session.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/features/history/widgets/matching_activity_tiles.dart';
import 'package:speedometer/features/history/widgets/sessionActivity.dart';

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
  List matchingActivity = [];
  assignData() {
    final pedometerProvider =
        Provider.of<PedoMeterSessionProvider>(context, listen: false);
    final pedometerSessions = pedometerProvider.pedometerSessions;
    for (var pedometerSession in pedometerSessions) {
      topMaxSpeedList.add(pedometerSession.maxSpeedInMS);
      topAvgSpeedList.add(pedometerSession.averageSpeedInMS);
      topDistanceList.add(pedometerSession.distanceInMeters);
      topDurationList.add(durationInMinutes(pedometerSession.sessionDuration));
    }
    topMaxSpeedList.sort((a, b) => b.compareTo(a));
    topAvgSpeedList.sort((a, b) => b.compareTo(a));
    topDistanceList.sort((a, b) => b.compareTo(a));
    topDurationList.sort((a, b) => b.compareTo(a));
    for (var e in topMaxSpeedList) {
      print(e);
    }
    matchingActivity = [
      {
        'activityType': 'Top Max Speed',
        'icon': Icons.local_fire_department,
        'topValue': topMaxSpeedList.isEmpty ? 0.0 : topMaxSpeedList[0],
        'matchingActivityValues': topMaxSpeedList,
        'valueUnit': 'mph'
      },
      {
        'activityType': 'Top Avg Speed',
        'icon': Icons.speed,
        'topValue': topAvgSpeedList.isEmpty ? 0.0 : topAvgSpeedList[0],
        'matchingActivityValues': topAvgSpeedList,
        'valueUnit': 'mph'
      },
      {
        'activityType': 'Top Distance',
        'icon': Icons.straighten,
        'topValue': topDistanceList.isEmpty ? 0.0 : topDistanceList[0],
        'matchingActivityValues': topDistanceList,
        'valueUnit': 'miles'
      },
      {
        'activityType': 'Top Duration',
        'icon': Icons.watch_later_outlined,
        'topValue': topDurationList.isEmpty ? 0.0 : topDurationList[0],
        'matchingActivityValues': topDurationList,
        'valueUnit': 'minutes'
      },
    ];
  }

  @override
  void initState() {
    assignData();
    super.initState();
  }

  double durationInMinutes(Duration? duration) {
    if (duration == null) {
      return 0.0;
    }

    final seconds = duration.inSeconds;
    return seconds / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    var pedometerSessionProvider =
        Provider.of<PedoMeterSessionProvider>(context);
    return Scaffold(
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
                // height: 220.h,
                width: double.maxFinite,
                padding: EdgeInsets.only(left: 15.w),
                decoration: BoxDecoration(
                  color: Color.fromARGB(246, 238, 238, 255),
                  borderRadius: BorderRadius.circular(BorderRadiusSizes.xs),
                  border: Border.all(
                      color: Color.fromARGB(246, 222, 222, 255), width: 2.sp),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: matchingActivity.length,
                  itemBuilder: (context, index) {
                    return MatchingActivityTile(
                      activityType: matchingActivity[index]['activityType'],
                      icon: matchingActivity[index]['icon'],
                      matchingActivityValues: matchingActivity[index]
                          ['matchingActivityValues'],
                      tileIndex: index,
                      tilesLength: matchingActivity.length,
                      topValue: matchingActivity[index]['topValue'],
                      valueUnit: matchingActivity[index]['valueUnit'],
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
                  color: Color.fromARGB(246, 238, 238, 255),
                  borderRadius: BorderRadius.circular(BorderRadiusSizes.xs),
                  border: Border.all(
                      color: Color.fromARGB(246, 222, 222, 255), width: 2.sp),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: pedometerSessionProvider.pedometerSessions.length,
                  itemBuilder: (context, index) {
                    return SessionActivityTile(
                      pedometerSession:
                          pedometerSessionProvider.pedometerSessions[index],
                      tileIndex: index,
                      tilesLength: matchingActivity.length,
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
