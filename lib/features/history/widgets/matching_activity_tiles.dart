import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speedometer/core/styling/text_styles.dart';

class MatchingActivityTile extends StatefulWidget {
  List<double> matchingActivityValues;
  int tileIndex;
  int tilesLength;
  IconData icon;
  String activityType;
  double topValue;
  String valueUnit;
  MatchingActivityTile(
      {super.key,
      required this.activityType,
      required this.icon,
      required this.matchingActivityValues,
      required this.tileIndex,
      required this.tilesLength,
      required this.topValue,required this.valueUnit});

  @override
  State<MatchingActivityTile> createState() => _MatchingActivityTileState();
}

class _MatchingActivityTileState extends State<MatchingActivityTile> {
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
                    style: AppTextStyles().mRegular,
                  ),
                ],
              ),
              Text(
                '  ${widget.topValue.toStringAsFixed(1)}',
                style: AppTextStyles().sRegular,
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
