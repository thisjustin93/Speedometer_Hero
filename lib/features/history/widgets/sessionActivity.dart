import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/styling/text_styles.dart';

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
      padding: EdgeInsets.symmetric(vertical: 5.h),
      decoration: BoxDecoration(
        border: widget.tileIndex < widget.tilesLength - 1
            ? Border(
                bottom: BorderSide(color: Colors.grey, width: 1.w),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 80.h,
            width: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              image: DecorationImage(
                  image: AssetImage(
                    'assets/images/sessionpath.png',
                  ),
                  fit: BoxFit.cover),
            ),
            // child: Image.asset(
            //   'assets/images/sessionpath.png',
            //   fit: BoxFit.cover,
            // ),
          ),
          // Image.asset(
          //   'assets/images/sessionpath.png',
          //   height: 80.h,
          //   width: 80.w,
          //   fit: BoxFit.cover,
          // ),
          SizedBox(
            width: 15.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Title",
                  style: AppTextStyles().mRegular,
                ),
                Text(
                  'Title',
                  style: AppTextStyles().sRegular,
                ),
                Text(
                  'Title',
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
