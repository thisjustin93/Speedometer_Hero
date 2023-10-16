import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SpeedometerWidget extends StatelessWidget {
  double altitude;
  SpeedometerWidget({super.key, required this.altitude});

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<UnitsProvider>(context).settings;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: settings.maximumGaugeSpeed.toDouble(),
          // interval: 20,
          labelOffset: isPortrait ? 15 : 18,
          radiusFactor: isPortrait ? 1.r : 1.8.r,
          pointers: <GaugePointer>[
            NeedlePointer(
                value: altitude > 0 ? altitude : 0,
                needleLength: isPortrait ? 0.95.h : 0.45.w,
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
              color: Theme.of(context).colorScheme.onPrimary),
          majorTickStyle: MajorTickStyle(
              length: 5,
              thickness: 4,
              color: Theme.of(context).colorScheme.onPrimary),
          minorTickStyle:
              MinorTickStyle(length: 3, thickness: 3, color: Colors.grey),
          axisLabelStyle: GaugeTextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
            fontSize: isPortrait ? 16.sp : 9.sp,
          ),
          showLastLabel: true,
          annotations: <GaugeAnnotation>[
            if (settings.showElevation)
              GaugeAnnotation(
                  widget: Container(
                      child: Column(children: <Widget>[
                    RichText(
                      text: TextSpan(
                        text: altitude > 0
                            ? altitude.toStringAsFixed(1)
                            : 0.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: isPortrait ? 25.sp : 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary),
                        children: [
                          TextSpan(
                            text: ' ${settings.elevationUnit}',
                            style: TextStyle(
                              fontSize: isPortrait ? 16.sp : 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ])),
                  angle: 90,
                  positionFactor: 1.6),
          ],
        ),
      ],
    );
  }
}
