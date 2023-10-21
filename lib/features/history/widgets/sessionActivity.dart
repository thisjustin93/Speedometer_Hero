import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/history/widgets/edit_bottomsheet.dart';

class SessionActivityTile extends StatefulWidget {
  PedometerSession pedometerSession;
  int tileIndex;
  int tilesLength;
  bool showCheckBox;
  VoidCallback deleteSession;
  SessionActivityTile(
      {super.key,
      required this.pedometerSession,
      required this.tileIndex,
      required this.tilesLength,
      required this.showCheckBox,
      required this.deleteSession});

  @override
  State<SessionActivityTile> createState() => _SessionActivityTileState();
}

class _SessionActivityTileState extends State<SessionActivityTile> {
  List<Map<String, IconData?>> activityIcons = [
    {"Cycle": Icons.directions_bike},
    {"None": null},
    {"Run": Icons.directions_run},
    {"Hike": Icons.hiking_rounded},
    {"Walk": Icons.directions_walk},
    {"Snowboard": Icons.snowboarding},
    {"Sail": Icons.sailing_outlined},
    {"Skateboard": Icons.skateboarding},
    {"Ski": Icons.downhill_skiing},
    {"Crosscountry Ski": Icons.downhill_skiing},
    {"Ship": Icons.sailing_outlined},
  ];
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<UnitsProvider>(context).settings;
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
          if (widget.showCheckBox)
            IconButton(
              onPressed: widget.deleteSession,
              icon: Icon(
                Icons.remove_circle,
                color: Colors.red,
              ),
            ),
          Container(
            height: 70.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
            ),
            width: 70.h,
            child: AppleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(widget.pedometerSession.startPoint!.latitude,
                      widget.pedometerSession.startPoint!.longitude),
                  zoom: 18),
              mapType: MapType.standard,
              polylines: Set<Polyline>.of([
                Polyline(
                  polylineId: PolylineId(
                      widget.pedometerSession.path!.polylineId.value),
                  color: Colors.blue,
                  points: List<LatLng>.from(
                    widget.pedometerSession.path!.points.map(
                      (e) => LatLng(e.latitude, e.longitude),
                    ),
                  ),
                  width: 1,
                ),
              ]),
            ),
          ),

          // Container(
          //   height: 70.h,
          //   width: 70.h,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(10.r),
          //     image: DecorationImage(
          //         image: AssetImage(
          //           'assets/images/sessionpath.png',
          //         ),
          //         fit: BoxFit.cover),
          //   ),
          // ),
          SizedBox(
            width: 15.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.pedometerSession.sessionTitle.contains('/') ||
                    widget.pedometerSession.activityType!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        activityIcons.singleWhere((element) =>
                                element.containsKey(
                                    widget.pedometerSession.activityType))[
                            widget.pedometerSession.activityType],
                        size: widget.pedometerSession.activityType == 'None'
                            ? 0
                            : null,
                        color: Colors.red,
                      ),
                      SizedBox(width: 4.w), // Adjust spacing as needed.
                      Text(
                        widget.pedometerSession.sessionTitle,
                        style: context.textStyles.mThick(),
                      ),
                    ],
                  ),
                ],
                if (widget.pedometerSession.sessionTitle.contains('/') &&
                    widget.pedometerSession.activityType!.isEmpty)
                  Text(
                    widget.pedometerSession.sessionTitle,
                    style: context.textStyles.mRegular(),
                  ),
                Text(
                  DateFormat("MMMM d',' y, h':'mm a")
                      .format(DateTime.parse(
                          widget.pedometerSession.startTime.toString()))
                      .toString(),
                  style: context.textStyles.sRegular(),
                ),
                Text(
                  "${convertDistance(widget.pedometerSession.distanceInMeters, settings.speedUnit == 'mph' ? 'mi' : settings.speedUnit == 'kmph' ? 'km' : 'm').toStringAsFixed(1)} ${settings.speedUnit == 'mph' ? "miles" : settings.speedUnit == 'kmph' ? "kilometers" : "meters"} \u2981 ${(widget.pedometerSession.sessionDuration.inSeconds / 60).toStringAsFixed(2)} minutes",
                  style: context.textStyles.sRegular(),
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
