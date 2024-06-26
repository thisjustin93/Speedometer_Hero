import 'dart:io';
import 'dart:math';

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
    {"None": null},
    {"Run": Icons.directions_run},
    {"Cycle": Icons.directions_bike},
    {"Motorcycle": Icons.two_wheeler},
    {"Car": Icons.directions_car},
    {"Train": Icons.directions_train},
    {"Plane": Icons.flight},
    {"Ship": Icons.sailing},
  ];
  // borderRadius: BorderRadius.only(
  //   topLeft: widget.tileIndex == 0 ? Radius.circular(8.r) : Radius.zero,
  //   topRight: widget.tileIndex == 0 ? Radius.circular(8.r) : Radius.zero,
  //   bottomLeft: widget.tileIndex == widget.tilesLength - 1
  //       ? Radius.circular(8.r)
  //       : Radius.zero,
  //   bottomRight: widget.tileIndex == widget.tilesLength - 1
  //       ? Radius.circular(8.r)
  //       : Radius.zero,
  // ),
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<UnitsProvider>(context).settings;
    return Container(
      // padding: EdgeInsets.only(top: 10.h, bottom: 10.h, left: 10.w),
      margin: EdgeInsets.only(left: 12.w),
      decoration: BoxDecoration(
        // color: Theme.of(context).colorScheme.primary,
        color: settings.darkTheme == null
            ? MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Color(0xff1c1c1e)
                : Color(0xffc6c6c6)
            : settings.darkTheme!
                ? Color(0xff1c1c1e)
                : Color(0xffc6c6c6),
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(10.0),
        //   topRight: Radius.circular(5.0),
        //   bottomLeft: Radius.circular(20.0),
        //   bottomRight: Radius.circular(15.0),
        // ),
        borderRadius: BorderRadius.only(
          topLeft: widget.tileIndex == 0 ? Radius.circular(8.r) : Radius.zero,
          topRight: widget.tileIndex == 0 ? Radius.circular(8.r) : Radius.zero,
          bottomLeft: widget.tileIndex == widget.tilesLength - 1
              ? Radius.circular(8.r)
              : Radius.zero,
          bottomRight: widget.tileIndex == widget.tilesLength - 1
              ? Radius.circular(8.r)
              : Radius.zero,
        ),
        // border: Border.all(
        //     color: settings.darkTheme == null
        //         ? MediaQuery.of(context).platformBrightness == Brightness.dark
        //             ? Color(0xff1c1c1e)
        //             : Color(0xffc6c6c6)
        //         : settings.darkTheme!
        //             ? Color(0xff1c1c1e)
        //             : Color(0xffc6c6c6),
        //     width: 2.w)
        // boxShadow: [
        //   BoxShadow(
        //       color: settings.darkTheme == null
        //           ? MediaQuery.of(context).platformBrightness ==
        //                   Brightness.dark
        //               ? Color(0xff1c1c1e)
        //               : Color(0xffc6c6c6)
        //           : settings.darkTheme!
        //               ? Color(0xff1c1c1e)
        //               : Color(0xffc6c6c6),
        //       spreadRadius: 2,
        //       offset: Offset(0, 0))
        // ]
        // borderRadius: BorderRadius.horizontal(
        //     left: Radius.circular(8.r), right: Radius.zero),
        // border: Border(
        //     top: widget.tileIndex == 0
        //         ? BorderSide(
        //             color: settings.darkTheme == null
        //                 ? MediaQuery.of(context).platformBrightness ==
        //                         Brightness.dark
        //                     ? Color(0xff1c1c1e)
        //                     : Color(0xffc6c6c6)
        //                 : settings.darkTheme!
        //                     ? Color(0xff1c1c1e)
        //                     : Color(0xffc6c6c6),
        //             width: 2.sp)
        //         : BorderSide.none,
        //     left: BorderSide(
        //         color: settings.darkTheme == null
        //             ? MediaQuery.of(context).platformBrightness ==
        //                     Brightness.dark
        //                 ? Color(0xff1c1c1e)
        //                 : Color(0xffc6c6c6)
        //             : settings.darkTheme!
        //                 ? Color(0xff1c1c1e)
        //                 : Color(0xffc6c6c6),
        //         width: 2.sp),
        //     right: BorderSide(
        //         color: settings.darkTheme == null
        //             ? MediaQuery.of(context).platformBrightness ==
        //                     Brightness.dark
        //                 ? Color(0xff1c1c1e)
        //                 : Color(0xffc6c6c6)
        //             : settings.darkTheme!
        //                 ? Color(0xff1c1c1e)
        //                 : Color(0xffc6c6c6),
        //         width: 2.sp),
        //     bottom: widget.tileIndex == widget.tilesLength - 1
        //         ? BorderSide(
        //             color: settings.darkTheme == null
        //                 ? MediaQuery.of(context).platformBrightness ==
        //                         Brightness.dark
        //                     ? Color(0xff1c1c1e)
        //                     : Color(0xffc6c6c6)
        //                 : settings.darkTheme!
        //                     ? Color(0xff1c1c1e)
        //                     : Color(0xffc6c6c6),
        //             width: 2.sp)
        //         : BorderSide.none),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: widget.tileIndex == 0 ? Radius.circular(8.r) : Radius.zero,
            topRight:
                widget.tileIndex == 0 ? Radius.circular(8.r) : Radius.zero,
            bottomLeft: widget.tileIndex == widget.tilesLength - 1
                ? Radius.circular(8.r)
                : Radius.zero,
            bottomRight: widget.tileIndex == widget.tilesLength - 1
                ? Radius.circular(8.r)
                : Radius.zero,
          ),
        ),
        margin: EdgeInsets.only(
            left: 2.w,
            right: 2.w,
            top: widget.tileIndex == 0 ? 2.h : 0,
            bottom: widget.tileIndex == widget.tilesLength - 1 ? 2.h : 0),
        padding: EdgeInsets.only(top: 10.h, bottom: 10.h, left: 10.w),
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
            Platform.isIOS
                ? Container(
                    height: 70.h,
                    decoration: BoxDecoration(),
                    width: 70.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: AppleMap(
                        initialCameraPosition: CameraPosition(
                            target: LatLng(
                                widget.pedometerSession.path!.points.isEmpty
                                    ? widget
                                        .pedometerSession.startPoint!.latitude
                                    : widget.pedometerSession.path!.points.first
                                        .latitude,
                                widget.pedometerSession.path!.points.isEmpty
                                    ? widget
                                        .pedometerSession.startPoint!.longitude
                                    : widget.pedometerSession.path!.points.first
                                        .longitude),
                            zoom: 18),
                        mapType: MapType.standard,
                        annotations: widget
                                .pedometerSession.path!.points.isEmpty
                            ? null
                            : (Set()
                              ..add(
                                Annotation(
                                    annotationId: AnnotationId(
                                        'start${widget.pedometerSession.sessionId}'),
                                    position: LatLng(
                                        widget.pedometerSession.path!.points
                                            .first.latitude,
                                        widget.pedometerSession.path!.points
                                            .first.longitude),
                                    icon: BitmapDescriptor.markerAnnotation),
                              )
                              ..add(
                                Annotation(
                                    annotationId: AnnotationId(
                                        'end${widget.pedometerSession.sessionId}'),
                                    position: LatLng(
                                        widget.pedometerSession.path!.points
                                            .last.latitude,
                                        widget.pedometerSession.path!.points
                                            .last.longitude),
                                    icon: BitmapDescriptor.markerAnnotation),
                              )),
                        polylines: widget.pedometerSession.path!.points.isEmpty
                            ? null
                            : Set<Polyline>.of([
                                Polyline(
                                  polylineId: PolylineId(widget
                                      .pedometerSession.path!.polylineId.value),
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
                  )
                : Container(
                    height: 70.h,
                    width: 70.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      image: DecorationImage(
                          image: AssetImage(
                            Random().nextInt(2) == 0
                                ? "assets/images/map.png"
                                : 'assets/images/sessionpath.png',
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
                  if (!widget.pedometerSession.sessionTitle.contains('-') ||
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
                        if (widget.pedometerSession.activityType != 'None')
                          SizedBox(width: 4.w), // Adjust spacing as needed.
                        SizedBox(
                          width: 165.w,
                          child: Text(
                            widget.pedometerSession.sessionTitle,
                            style: context.textStyles.mThick().copyWith(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 15.sp),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.pedometerSession.sessionTitle.contains('-') &&
                      widget.pedometerSession.activityType!.isEmpty)
                    Text(
                      widget.pedometerSession.sessionTitle,
                      style: context.textStyles.mRegular(),
                      overflow: TextOverflow.fade,
                    ),
                  Text(
                    DateFormat("MMMM d',' y, h':'mm a")
                        .format(DateTime.parse(
                            widget.pedometerSession.startTime.toString()))
                        .toString(),
                    style: context.textStyles.sRegular(),
                  ),
                  Text(
                    "${convertDistance(widget.pedometerSession.distanceInMeters, settings.speedUnit == 'mph' ? 'mi' : settings.speedUnit == 'kmph' ? 'km' : 'm').toStringAsFixed(1)} ${settings.speedUnit == 'mph' ? "miles" : settings.speedUnit == 'kmph' ? "kilometers" : settings.speedUnit == 'knots' ? "knots" : "meters"} \u2981 ${(widget.pedometerSession.sessionDuration.inSeconds / 60).toStringAsFixed(2)} minutes",
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
      ),
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  final double leftMargin;
  final bool isFirstTile;
  final bool isLastTile;

  MyCustomClipper({
    required this.leftMargin,
    required this.isFirstTile,
    required this.isLastTile,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = 8.r; // Adjust the radius as needed

    if (isFirstTile) {
      path.moveTo(leftMargin, 0);
    } else {
      path.moveTo(leftMargin, 0);
    }

    path.lineTo(size.width, 0);

    if (isLastTile) {
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      );
    } else {
      path.lineTo(size.width, size.height);
    }

    path.lineTo(leftMargin, size.height);

    if (isFirstTile) {
      path.lineTo(leftMargin, radius);
      path.quadraticBezierTo(
        leftMargin,
        0,
        leftMargin + radius,
        0,
      );
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
