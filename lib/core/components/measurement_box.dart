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
  String measurement;
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
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Container(
      height: isPortrait ? 80.h : 125.h,
      width: isPortrait ? 173.w : width * 0.207,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: settings.darkTheme == null
              ? MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? Color(0xff1c1c1e)
                  : Color(0xffc6c6c6)
              : settings.darkTheme!
                  ? Color(0xff1c1c1e)
                  : Color(0xffc6c6c6),
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
                ? measurement == '-99'
                    ? "--"
                    : '${Duration(seconds: int.parse(measurement)).inMinutes.remainder(60)}:${Duration(seconds: int.parse(measurement)).inSeconds.remainder(60)} $measurementUnit'
                : '${measurement} $measurementUnit',
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
