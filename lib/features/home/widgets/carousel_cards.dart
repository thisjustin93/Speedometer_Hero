import 'dart:async';
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
      this.speed = 0,
      this.avgSpeed = 0,
      this.distanceCovered = 0,
      this.maxSpeed = 0,
      this.duration = Duration.zero,
      this.googleMapAPI = '',
      this.onPressed});
  String googleMapAPI = '';
  int cardIndex;
  double speed = 0;
  double maxSpeed = 0;
  double avgSpeed = 0;
  Position? position;
  googlemaps.Polyline? polyline;
  double distanceCovered = 0;
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
              height: isPortrait ? 300.h : 230.h,
              width: isPortrait
                  ? 320.w
                  : (MediaQuery.of(context).size.width * 0.46),
              padding: isPortrait
                  ? EdgeInsets.symmetric(horizontal: 25.w)
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
                                      : "M/S",
                              style: context.textStyles.mRegular().copyWith(
                                  fontSize: isPortrait ? null : 10.sp),
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Text(
                              widget.speed.toStringAsFixed(0),
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
                          measurementUnit: settings.speedUnit == "mph"
                              ? 'MPH'
                              : settings.speedUnit == 'kmph'
                                  ? 'KM/H'
                                  : 'M/S'),
                      MeasurementBox(
                          boxType: 'Avg Speed',
                          measurement:
                              convertSpeed(widget.avgSpeed, settings.speedUnit),
                          // measurement: distanceCovered == 0 ||
                          //         duration == Duration.zero
                          //     ? 0
                          //     : distanceCovered /
                          //         (duration.inSeconds /
                          //             (settings.speedUnit == 'mps' ? 1 : 3600)),
                          measurementUnit: settings.speedUnit == "mph"
                              ? 'MPH'
                              : settings.speedUnit == 'kmph'
                                  ? 'KM/H'
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
                          measurementUnit: settings.speedUnit == "mph"
                              ? 'Mi'
                              : settings.speedUnit == 'kmph'
                                  ? 'KM'
                                  : 'M'),
                      MeasurementBox(
                          boxType: 'Duration',
                          measurement: widget.duration.inSeconds.toDouble(),
                          measurementUnit: ''),
                    ],
                  ),
                ],
              ),
            ),
          )
        : widget.position != null
            ? Container(
                padding: isPortrait
                    ? EdgeInsets.symmetric(horizontal: 25.w)
                    : EdgeInsets.only(
                        top: (height * 0.1),
                        left: width * 0.01,
                        right: width * 0.02),
                height: 260.h,
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
                              zoom: 20,
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
                                points: List<LatLng>.from(
                                    widget.polyline!.points.map((e) =>
                                        LatLng(e.latitude, e.longitude))),
                              ),
                            ]),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 7,
                        left: 30,
                        child: Text(
                          widget.speed.toStringAsFixed(0),
                          style: context.textStyles.lRegular(),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                padding: isPortrait
                    ? EdgeInsets.symmetric(horizontal: 25.w)
                    : EdgeInsets.only(
                        top: (height * 0.1),
                        left: width * 0.01,
                        right: width * 0.02),
                height: 260.h,
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
                ));
  }
}
