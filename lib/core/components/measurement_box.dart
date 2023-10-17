import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/utils/extensions/context.dart';

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
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    var settings = Provider.of<UnitsProvider>(context).settings;
    return Container(
      height: isPortrait ? 55.h : 140.h,
      width: isPortrait ? 158.w : 80.w,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        // color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: settings.darkTheme ? Color(0xff1c1c1e) : Color(0xffc6c6c6),
          // color: Colors.white,
          width: isPortrait ? 2.sp : 1.sp,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(boxType,
              style: context.textStyles.mRegular().copyWith(
                    fontSize: isPortrait ? null : 8.sp,
                  )),
          Text(
            boxType == 'Duration'
                ? '${Duration(seconds: measurement.toInt()).inMinutes.remainder(60)}:${Duration(seconds: measurement.toInt()).inSeconds.remainder(60)} $measurementUnit'
                : '${measurement.toStringAsFixed(1)} $measurementUnit',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: isPortrait ? 15.sp : 10.sp,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          )
        ],
      ),
    );
  }
}
