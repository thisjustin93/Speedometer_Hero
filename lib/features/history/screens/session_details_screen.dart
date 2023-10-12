import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:speedometer/features/history/widgets/matching_activity_tiles.dart';

class SessionDetailsScreen extends StatefulWidget {
  PedometerSession session;
  SessionDetailsScreen({super.key, required this.session});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  List tileData = [];
  @override
  void initState() {
    tileData = [
      {
        'activityType': 'Max Speed',
        'icon': Icons.local_fire_department,
        'value': widget.session.maxSpeedInMS,
        'valueUnit': 'mph'
      },
      {
        'activityType': 'Avg Speed',
        'icon': Icons.speed,
        'value': widget.session.averageSpeedInMS,
        'valueUnit': 'mph'
      },
      {
        'activityType': 'Top Distance',
        'icon': Icons.straighten,
        'value': widget.session.distanceInMeters,
        'valueUnit': 'miles'
      },
      {
        'activityType': 'Top Duration',
        'icon': Icons.watch_later_outlined,
        'value': widget.session.sessionDuration,
        'valueUnit': 'minutes'
      },
    ];

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
    return Scaffold(
      backgroundColor: Color(0xFFEBEBE3),
      appBar: AppBar(
        backgroundColor: Color(0xFFF7F7F7),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.chevron_left,
              size: 28.sp,
            )),
        title: Text(
          '${widget.session.sessionTitle}',
          style: AppTextStyles().mThick,
        ),
        centerTitle: true,
        actionsIconTheme: IconThemeData(),
        actions: [
          InkWell(
            child: Icon(
              Icons.edit_note,
              size: 28.sp,
            ),
          ),
          SizedBox(
            width: 5.w,
          ),
          InkWell(
            child: Icon(
              Icons.file_upload_outlined,
              size: 28.sp,
            ),
          ),
          SizedBox(
            width: 5.w,
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 15.h),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.w),
                    child: Text(
                      widget.session.sessionTitle,
                      style: AppTextStyles().mThick,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.w, bottom: 5.h),
                    child: Text(DateFormat("MMMM d',' y h':'mm a")
                        .format(DateTime.parse(widget.session.sessionId))
                        .toString()),
                  ),
                  Image.asset(
                    'assets/images/map.png',
                    height: 180.h,
                    width: double.maxFinite,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 6.h, horizontal: 15.w),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      tileData[index]['icon'],
                                      color: Colors.red,
                                      size: 25.sp,
                                    ),
                                    SizedBox(
                                      width: 8.w,
                                    ),
                                    Text(
                                      tileData[index]['activityType'],
                                      style: AppTextStyles().mRegular,
                                    ),
                                  ],
                                ),
                                Text(
                                  tileData[index]['activityType'] ==
                                          'Top Duration'
                                      ? '  ${durationInMinutes(tileData[index]['value']).toStringAsFixed(1)}  ${tileData[index]['valueUnit']}'
                                      : tileData[index]['activityType'] ==
                                              'Top Distance'
                                          ? '  ${tileData[index]['value'].toStringAsFixed(1)} ${tileData[index]['valueUnit']}'
                                          : tileData[index]['activityType'] ==
                                                  'Top Max Speed'
                                              ? '  ${tileData[index]['value'].toStringAsFixed(1)} ${tileData[index]['valueUnit']}'
                                              : '  ${tileData[index]['value'].toStringAsFixed(1)} ${tileData[index]['valueUnit']}', // Top Average Speed
                                  style: AppTextStyles().sRegular,
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 30.w, top: 10.h),
                              child: index < 3
                                  ? Divider(
                                      height: 2.h,
                                      color: Color(0xffB1B0B2),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            InkWell(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    8.h,
                  ),
                  color: Colors.white,
                ),
                height: 50.h,
                width: double.maxFinite,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Speed Data',
                      style: AppTextStyles().mRegular,
                    ),
                    Icon(Icons.chevron_right)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
