import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CompassWidget extends StatelessWidget {
  double direction;
  CompassWidget({super.key, required this.direction});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Transform.rotate(
      angle: ((direction) * (pi / 180) * -1),
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            startAngle: 270,
            endAngle: 270,
            minimum: 0,
            maximum: 360,
            interval: 45,
            labelOffset: 5,
            radiusFactor: 0.4,
            onLabelCreated: (value) {
              value.labelStyle = GaugeTextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isPortrait ? 15.sp : 9.sp,
                  color: Theme.of(context).colorScheme.onPrimary);
              if (value.text == '360' || value.text == '0') {
                value.text = 'N';
                value.labelStyle = GaugeTextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: isPortrait ? 15.sp : 9.sp);
              } else if (value.text == '90') {
                value.text = 'E';
              } else if (value.text == '180') {
                value.text = 'S';
              } else if (value.text == '270') {
                value.text = 'W';
              } else {
                value.text = '';
              }
            },
            showAxisLine: false,
            minorTicksPerInterval: 4,
            majorTickStyle: MajorTickStyle(
              length: 6,
              thickness: 2,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            minorTickStyle:
                MinorTickStyle(length: 4, thickness: 2, color: Colors.grey),
            axisLabelStyle: GaugeTextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              // fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            showLastLabel: true,
          ),
        ],
      ),
    );
  }
}
