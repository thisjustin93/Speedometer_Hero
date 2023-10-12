import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';

class MeasurementBox extends StatelessWidget {
  String boxType;
  double measurement;
  String measurementUnit;
  MeasurementBox(
      {super.key,
      required this.boxType,
      required this.measurement,
      required this.measurementUnit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55.h,
      width: 158.w,
      decoration: BoxDecoration(
        // color: Color(0xfff6f6f6),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          // color: Color(0xffc6c6c6),
          color: Colors.white,
          width: 2.sp,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(boxType, style: AppTextStyles().mRegular),
          Text(
            boxType == 'Duration'
                ? '${Duration(seconds: measurement.toInt()).inMinutes.remainder(60)}:${Duration(seconds: measurement.toInt()).inSeconds.remainder(60)} $measurementUnit'
                : '${measurement.toStringAsFixed(1)} $measurementUnit',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17.sp),
          )
        ],
      ),
    );
  }
}
