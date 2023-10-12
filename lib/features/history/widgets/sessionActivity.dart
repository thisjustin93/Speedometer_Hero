import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:speedometer/core/utils/convert_distance.dart';

class SessionActivityTile extends StatefulWidget {
  PedometerSession pedometerSession;
  int tileIndex;
  int tilesLength;
  SessionActivityTile(
      {super.key,
      required this.pedometerSession,
      required this.tileIndex,
      required this.tilesLength});

  @override
  State<SessionActivityTile> createState() => _SessionActivityTileState();
}

class _SessionActivityTileState extends State<SessionActivityTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        border: widget.tileIndex < widget.tilesLength - 1
            ? Border(
                bottom: BorderSide(color: Color(0xffB1B0B2), width: 1.w),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 70.h,
            width: 70.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/sessionpath.png',
                  ),
                  fit: BoxFit.cover),
            ),
          ),
          SizedBox(
            width: 15.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pedometerSession.sessionTitle,
                  style: AppTextStyles().mRegular,
                ),
                Text(
                  DateFormat("MMMM d',' y, h':'mm a")
                      .format(DateTime.parse(widget.pedometerSession.sessionId))
                      .toString(),
                  style: AppTextStyles().sRegular,
                ),
                Text(
                  "${convertDistance(widget.pedometerSession.distanceInMeters, 'mi').toStringAsFixed(1)} miles \u2981 ${(widget.pedometerSession.sessionDuration.inSeconds / 60).toStringAsFixed(2)} minutes",
                  style: AppTextStyles().sRegular,
                )
              ],
            ),
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
