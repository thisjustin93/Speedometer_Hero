import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/utils/extensions/context.dart';

class MatchingActivityTile extends StatefulWidget {
  // List<double> matchingActivityValues;
  int tileIndex;
  int tilesLength;
  IconData icon;
  String activityType;
  PedometerSession session;
  String valueUnit;
  MatchingActivityTile(
      {super.key,
      required this.activityType,
      required this.icon,
      // required this.matchingActivityValues,
      required this.tileIndex,
      required this.tilesLength,
      required this.session,
      required this.valueUnit});

  @override
  State<MatchingActivityTile> createState() => _MatchingActivityTileState();
}

class _MatchingActivityTileState extends State<MatchingActivityTile> {
  double durationInMinutes(Duration? duration) {
    if (duration == null) {
      return 0.0;
    }

    final seconds = duration.inSeconds;
    return seconds / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<UnitsProvider>(context).settings;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      decoration: BoxDecoration(
        border: widget.tileIndex < widget.tilesLength - 1
            ? Border(
                bottom: BorderSide(color: Color(0xffB1B0B2), width: 1.w),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.red,
                    size: 25.sp,
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                  Text(
                    widget.activityType,
                    style: context.textStyles.mRegular(),
                  ),
                ],
              ),
              Text(
                widget.activityType == 'Top Duration'
                    ? '  ${durationInMinutes(widget.session.sessionDuration).toStringAsFixed(1)}  ${widget.valueUnit}'
                    : widget.activityType == 'Top Distance'
                        ? '  ${convertDistance(widget.session.distanceInMeters, 'mi').toStringAsFixed(1)} ${widget.valueUnit}'
                        : widget.activityType == 'Top Max Speed'
                            ? '  ${convertSpeed(widget.session.maxSpeedInMS, widget.valueUnit).toStringAsFixed(1)} ${widget.valueUnit}'
                            : '  ${convertSpeed(widget.session.averageSpeedInMS, widget.valueUnit).toStringAsFixed(1)} ${widget.valueUnit}', // Top Average Speed
                style: context.textStyles.sRegular(),
              )
            ],
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 30.sp,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
