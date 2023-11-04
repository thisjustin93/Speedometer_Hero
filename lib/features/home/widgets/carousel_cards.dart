import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as googlemaps;
import 'package:provider/provider.dart';
import 'package:speedometer/core/components/measurement_box.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/home/widgets/duration_counter.dart';

class FancyCard extends StatefulWidget {
  FancyCard(
      {super.key,
      required this.cardIndex,
      this.position,
      this.polyline,
      this.speed = '0',
      this.avgSpeed = '0',
      this.distanceCovered = '0',
      this.maxSpeed = '0',
      this.duration = Duration.zero,
      this.googleMapAPI = '',
      this.onPressed});
  String googleMapAPI = '';
  int cardIndex;
  String speed = '0';
  String maxSpeed = '0';
  String avgSpeed = '0';
  Position? position;
  googlemaps.Polyline? polyline;
  String distanceCovered = '0';
  var duration = Duration.zero;
  VoidCallback? onPressed = () {};

  @override
  State<FancyCard> createState() => _FancyCardState();
}

class _FancyCardState extends State<FancyCard> {
  AppleMapController? mapController;

  void _onMapCreated(AppleMapController controller) {
    mapController = controller;
  }

  CameraPosition? cameraPosition;

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<UnitsProvider>(context).settings;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return widget.googleMapAPI.isEmpty
        ? Card(
            color: Theme.of(context).colorScheme.background,
            borderOnForeground: false,
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Container(
              color: Theme.of(context).colorScheme.background,
              height: isPortrait ? 310.h : 230.h,
              width: isPortrait
                  ? 320.w
                  : (MediaQuery.of(context).size.width * 0.46),
              padding: isPortrait
                  ? EdgeInsets.symmetric(horizontal: 5)
                  : EdgeInsets.only(
                      top: (height * 0.1),
                      left: width * 0.02,
                      right: width * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: settings.darkTheme == null
                              ? MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? Color(0xff1c1c1e)
                                  : Color(0xffc6c6c6)
                              : settings.darkTheme!
                                  ? Color(0xff1c1c1e)
                                  : Color(0xffc6c6c6),
                          width: isPortrait ? 2.sp : 1.sp),
                    ),
                    // width: isPortrait ? null : 170.w,
                    height: isPortrait ? 140.h : 280.h,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 35.w,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: isPortrait ? 12.sp : 0.sp,
                            ),
                            Text(
                              settings.speedUnit == 'mph'
                                  ? 'MPH'
                                  : settings.speedUnit == 'kmph'
                                      ? "KMPH"
                                      : settings.speedUnit == 'knots'
                                          ? "KNOTS"
                                          : "M/S",
                              style: context.textStyles.mRegular().copyWith(
                                  fontSize: isPortrait ? null : 10.sp),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              widget.speed,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: isPortrait ? 100.sp : 50.sp,
                                  height: 0.7),
                            )
                          ],
                        ),
                        IconButton(
                            alignment: Alignment.center,
                            constraints: BoxConstraints(
                                maxHeight: 35.sp, maxWidth: 35.sp),
                            icon: Transform.flip(
                              flipX: true,
                              child: Transform.rotate(
                                angle: -0.4,
                                child: Icon(
                                  Icons.replay,
                                  size: isPortrait ? 30.sp : 20.sp,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            onPressed: widget.onPressed
                            // size: 35.sp,
                            )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: isPortrait ? 4.sp : 2.sp,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MeasurementBox(
                          boxType: 'Max Speed',
                          measurement: widget.maxSpeed,
                          measurementUnit: widget.maxSpeed == '--'
                              ? ''
                              : settings.speedUnit == "mph"
                                  ? 'MPH'
                                  : settings.speedUnit == 'kmph'
                                      ? 'KM/H'
                                      : settings.speedUnit == 'knots'
                                          ? "KNOTS"
                                          : 'M/S'),
                      MeasurementBox(
                          boxType: 'Avg Speed',
                          measurement: widget.avgSpeed,
                          // measurement: distanceCovered == 0 ||
                          //         duration == Duration.zero
                          //     ? 0
                          //     : distanceCovered /
                          //         (duration.inSeconds /
                          //             (settings.speedUnit == 'mps' ? 1 : 3600)),
                          measurementUnit: widget.maxSpeed == '--'
                              ? ''
                              : settings.speedUnit == "mph"
                                  ? 'MPH'
                                  : settings.speedUnit == 'kmph'
                                      ? 'KM/H'
                                      : settings.speedUnit == 'knots'
                                          ? "KNOTS"
                                          : 'M/S'),
                    ],
                  ),
                  SizedBox(
                    height: isPortrait ? 4.sp : 2.sp,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MeasurementBox(
                          boxType: 'Distance',
                          measurement: widget.distanceCovered,
                          measurementUnit: widget.maxSpeed == '--'
                              ? ''
                              : settings.speedUnit == "mph"
                                  ? 'Mi'
                                  : settings.speedUnit == 'kmph'
                                      ? 'KM'
                                      : settings.speedUnit == 'knots'
                                          ? "KNOTS"
                                          : 'M'),
                      MeasurementBox(
                          boxType: 'Duration',
                          measurement: widget.duration.inSeconds.toString(),
                          measurementUnit: ''),
                    ],
                  ),
                ],
              ),
            ),
          )
        : widget.position != null && Platform.isIOS
            ? Container(
                padding: isPortrait
                    ? EdgeInsets.symmetric(horizontal: 5.w)
                    : isPortrait
                        ? EdgeInsets.symmetric(horizontal: 5.w)
                        : EdgeInsets.only(
                            top: (height * 0.1),
                            // left: width * 0.02,
                            right: width * 0.02,
                            bottom: height * 0.06),
                height: 300.h,
                // width: isPortrait ? 320.w : 180.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: settings.darkTheme == null
                            ? MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Color(0xff1c1c1e)
                                : Color(0xffc6c6c6)
                            : settings.darkTheme!
                                ? Color(0xff1c1c1e)
                                : Color(0xffc6c6c6),
                        width: isPortrait ? 2.sp : 1.sp),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: isPortrait ? width : width * 0.43),
                          child: AppleMap(
                            onMapCreated: _onMapCreated,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(widget.position!.latitude,
                                  widget.position!.longitude),
                              zoom: 25,
                            ),
                            gestureRecognizers:
                                <Factory<OneSequenceGestureRecognizer>>[
                              new Factory<OneSequenceGestureRecognizer>(
                                () => new EagerGestureRecognizer(),
                              ),
                            ].toSet(),
                            trafficEnabled: true,
                            trackingMode: TrackingMode.followWithHeading,
                            zoomGesturesEnabled: true,
                            mapType: MapType.standard,
                            scrollGesturesEnabled: true,

                            // onCameraMove: (position) async {
                            //   cameraPosition = position;
                            //   print("Position: $position");
                            //   if (mapController != null) {
                            //     await mapController!.animateCamera(
                            //         CameraUpdate.newCameraPosition(position));
                            //   }
                            // },
                            // onLongPress: (argument) async {
                            //   if (mapController != null) {
                            //     await mapController!
                            //         .moveCamera(CameraUpdate.newLatLng(argument));
                            //   }
                            // },
                            polylines: Set<Polyline>.of([
                              Polyline(
                                polylineId: PolylineId(
                                    widget.polyline!.polylineId.value),
                                color: widget.polyline!.color,
                                width: 3,
                                points: List<LatLng>.from(
                                    widget.polyline!.points.map((e) =>
                                        LatLng(e.latitude, e.longitude))),
                              ),
                            ]),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 23.h,
                        left: 5.w,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white.withOpacity(0.6),
                          ),
                          height: 40.h,
                          width: 80.w,
                          alignment: Alignment.center,
                          child: Text(
                            widget.speed,
                            // style: context.textStyles.lRegular(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontSize: 35.sp,
                              decoration: TextDecoration.none,
                              letterSpacing: 0,
                              color: Colors.black.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  Container(
                      padding: isPortrait
                          ? EdgeInsets.symmetric(horizontal: 5.w)
                          : EdgeInsets.only(
                              top: (height * 0.1),
                              left: width * 0.01,
                              right: width * 0.02),
                      height: 260.h,
                      width: isPortrait ? width : width * 0.43,
                      // decoration: BoxDecoration(
                      //   color: Theme.of(context).primaryColor,
                      //   borderRadius: BorderRadius.circular(8.r),
                      //   border: Border.all(
                      //       color: settings.darkTheme == null
                      //           ? MediaQuery.of(context).platformBrightness ==
                      //                   Brightness.dark
                      //               ? Color(0xff1c1c1e)
                      //               : Color(0xffc6c6c6)
                      //           : settings.darkTheme!
                      //               ? Color(0xff1c1c1e)
                      //               : Color(0xffc6c6c6),
                      //       width: isPortrait ? 2.sp : 1.sp),
                      // ),
                      child: Image.asset(
                        widget.googleMapAPI,
                        fit: BoxFit.cover,
                      )),
                  Positioned(
                    bottom: 8,
                    left: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white.withOpacity(0.5),
                      ),
                      height: 45.h,
                      width: 80.w,
                      alignment: Alignment.center,
                      child: Text(
                        widget.speed,
                        // style: context.textStyles.lRegular(),
                        style: TextStyle(
                          height: 1,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontSize: 40.sp,
                          decoration: TextDecoration.none,
                          letterSpacing: 0,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              );
  }
}
