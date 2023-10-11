import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedometerWidget extends StatelessWidget {
  double speed;
  SpeedometerWidget({super.key, required this.speed});

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 200,
          labelOffset: 15,
          radiusFactor: 0.85.r,
          pointers: <GaugePointer>[
            NeedlePointer(
                value: speed > 0 ? speed : 0,
                needleLength: 0.95.h,
                enableAnimation: true,
                animationType: AnimationType.ease,
                needleStartWidth: 0.5,
                needleEndWidth: 3.w,
                needleColor: Colors.red,
                knobStyle: KnobStyle(knobRadius: 0.09))
          ],
          axisLineStyle: AxisLineStyle(
              thicknessUnit: GaugeSizeUnit.factor,
              thickness: 0.03,
              color: Colors.black),
          majorTickStyle:
              MajorTickStyle(length: 5, thickness: 4, color: Colors.black),
          minorTickStyle:
              MinorTickStyle(length: 3, thickness: 3, color: Colors.grey),
          axisLabelStyle: GaugeTextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 16.sp,
          ),
          showLastLabel: true,
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
                widget: Container(
                    child: Column(children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: speed > 0
                          ? speed.toStringAsFixed(1)
                          : 0.toStringAsFixed(1),
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      children: [
                        TextSpan(
                          text: ' ft/s',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ])),
                angle: 90,
                positionFactor: 1.85),
          ],
        ),
      ],
    );
  }
}
