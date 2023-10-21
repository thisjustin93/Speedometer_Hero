import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/services/hive_database_services.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/history/widgets/edit_bottomsheet.dart';
import 'package:speedometer/features/history/widgets/matching_activity_tiles.dart';
import 'package:speedometer/features/history/widgets/share_bottomsheet.dart';
import 'package:speedometer/features/history/widgets/speed_data_bottomsheet.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:geolocator/geolocator.dart' as geolocator;

class SessionDetailsScreen extends StatefulWidget {
  PedometerSession session;
  SessionDetailsScreen({super.key, required this.session});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  List tileData = [];

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
  double durationInMinutes(Duration? duration) {
    if (duration == null) {
      return 0.0;
    }

    final seconds = duration.inSeconds;
    return seconds / 60.0;
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<UnitsProvider>(context).settings;
    tileData = [
      {
        'activityType': 'Max Speed',
        'icon': Icons.local_fire_department,
        'value': widget.session.maxSpeedInMS,
        'valueUnit': settings.speedUnit
      },
      {
        'activityType': 'Avg Speed',
        'icon': Icons.speed,
        'value': widget.session.averageSpeedInMS,
        'valueUnit': settings.speedUnit
      },
      {
        'activityType': 'Top Distance',
        'icon': Icons.straighten,
        'value': widget.session.distanceInMeters,
        'valueUnit': settings.speedUnit == 'mph'
            ? "miles"
            : settings.speedUnit == 'kmph'
                ? "kilometers"
                : "meters"
      },
      {
        'activityType': 'Top Duration',
        'icon': Icons.watch_later_outlined,
        'value': widget.session.sessionDuration,
        'valueUnit': 'minutes'
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        // backgroundColor: const Color(0xFFF7F7F7),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.chevron_left,
              size: 28.sp,
              color: Theme.of(context).colorScheme.onPrimary,
            )),
        title: Text(
          '${widget.session.sessionTitle}',
          style: context.textStyles.mThick(),
        ),
        centerTitle: true,
        actionsIconTheme: const IconThemeData(),
        actions: [
          InkWell(
            onTap: () async {
              editBottomSheet(
                context,
                widget.session,
                () {
                  setState(() {});
                },
              );
            },
            child: Icon(
              Icons.edit_note,
              size: 28.sp,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          SizedBox(
            width: 5.w,
          ),
          InkWell(
            onTap: () {
              shareBottomSheet(context, widget.session);
            },
            child: Icon(
              Icons.file_upload_outlined,
              size: 28.sp,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          SizedBox(
            width: 5.w,
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 15.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: settings.darkTheme
                        ? Color(0xff1c1c1e)
                        : Color(0xffc6c6c6),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 10.w,
                        ),
                        if (widget.session.activityType!.isNotEmpty)
                          Icon(
                            activityIcons.singleWhere((element) => element
                                    .containsKey(widget.session.activityType))[
                                widget.session.activityType],
                            color: Colors.red,
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 15.w),
                              child: Text(
                                widget.session.sessionTitle,
                                style: context.textStyles.mThick(),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.w, bottom: 5.h),
                              child: Text(
                                DateFormat("MMMM d',' y h':'mm a")
                                    .format(DateTime.parse(
                                        widget.session.startTime.toString()))
                                    .toString(),
                                style: context.textStyles.mRegular(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: 180.h,
                      width: double.maxFinite,
                      child: AppleMap(
                        initialCameraPosition: CameraPosition(
                            target: LatLng(widget.session.startPoint!.latitude,
                                widget.session.startPoint!.longitude),
                            zoom: 20),
                        zoomGesturesEnabled: true,
                        gestureRecognizers:
                            <Factory<OneSequenceGestureRecognizer>>[
                          new Factory<OneSequenceGestureRecognizer>(
                            () => new EagerGestureRecognizer(),
                          ),
                        ].toSet(),
                        mapType: MapType.standard,
                        scrollGesturesEnabled: true,
                        annotations: Set()
                          ..add(
                            Annotation(
                                annotationId: AnnotationId('start'),
                                position: LatLng(
                                    widget.session.startPoint!.latitude,
                                    widget.session.startPoint!.longitude),
                                icon: BitmapDescriptor.markerAnnotation),
                          )
                          ..add(
                            Annotation(
                                annotationId: AnnotationId('end'),
                                position: LatLng(
                                    widget.session.endPoint!.latitude,
                                    widget.session.endPoint!.longitude),
                                icon: BitmapDescriptor.markerAnnotation),
                          ),
                        polylines: Set<Polyline>.of([
                          Polyline(
                            polylineId: PolylineId(
                                widget.session.path!.polylineId.value),
                            color: widget.session.path!.color,
                            points: List<LatLng>.from(
                              widget.session.path!.points.map(
                                (e) => LatLng(e.latitude, e.longitude),
                              ),
                            ),
                            width: 3,
                          ),
                        ]),
                      ),
                    ),

                    // Image.asset(
                    //   'assets/images/map.png',
                    //   height: 180.h,
                    //   width: double.maxFinite,
                    //   fit: BoxFit.cover,
                    // ),
                    SizedBox(
                      height: 5.h,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 6.h, horizontal: 15.w),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        tileData[index]['icon'],
                                        color: Colors.red,
                                        size: 25.sp,
                                      ),
                                      SizedBox(
                                        width: 8.w,
                                      ),
                                      Text(
                                        tileData[index]['activityType'],
                                        style: context.textStyles.mRegular(),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    tileData[index]['activityType'] ==
                                            'Top Duration'
                                        ? '  ${durationInMinutes(tileData[index]['value']).toStringAsFixed(1)}  ${tileData[index]['valueUnit']}'
                                        : tileData[index]['activityType'] ==
                                                'Top Distance'
                                            ? '  ${convertDistance(tileData[index]['value'], settings.speedUnit == 'mph' ? 'mi' : settings.speedUnit == 'kmph' ? 'km' : 'm').toStringAsFixed(1)} ${tileData[index]['valueUnit']}'
                                            : tileData[index]['activityType'] ==
                                                    'Max Speed'
                                                ? '  ${convertSpeed(tileData[index]['value'], settings.speedUnit).toStringAsFixed(1)} ${tileData[index]['valueUnit']}'
                                                : '  ${convertSpeed(tileData[index]['value'], settings.speedUnit).toStringAsFixed(1)} ${tileData[index]['valueUnit']}', // Top Average Speed
                                    style: context.textStyles.sRegular(),
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 30.w, top: 10.h),
                                child: index < 3
                                    ? Divider(
                                        height: 2.h,
                                        color: const Color(0xffB1B0B2),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              InkWell(
                onTap: () {
                  speedDataBottomSheet(
                      context,
                      widget.session.geoPositions!
                          .map((e) => DateFormat("MMMM d, y  'at'  h:mm a")
                              .format(e.timestamp!))
                          .toList(),
                      widget.session.geoPositions!.map((e) => e.speed).toList(),
                      settings,
                      widget.session);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      8.h,
                    ),
                    border: Border.all(
                      color: settings.darkTheme
                          ? Color(0xff1c1c1e)
                          : Color(0xffc6c6c6),
                      width: 2,
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  height: 50.h,
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Speed Data',
                        style: context.textStyles.mRegular(),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: settings.darkTheme
                        ? Color(0xff1c1c1e)
                        : Color(0xffc6c6c6),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      height: 140.h,
                      child: SfCartesianChart(
                          // primaryXAxis: DateTimeAxis(),
                          primaryXAxis: DateTimeAxis(
                              majorGridLines: const MajorGridLines(width: 0),
                              minorGridLines: const MinorGridLines(width: 0),
                              isVisible: true),
                          primaryYAxis: NumericAxis(
                              majorGridLines: const MajorGridLines(width: 0),
                              minorGridLines: const MinorGridLines(width: 0),
                              isVisible: true),
                          series: <ChartSeries>[
                            LineSeries<geolocator.Position, DateTime>(
                              dataSource: widget.session.geoPositions!,
                              xValueMapper: (geolocator.Position position, _) =>
                                  position.timestamp,
                              yValueMapper: (geolocator.Position position, _) =>
                                  convertSpeed(
                                      position.speed, settings.speedUnit),
                            )
                          ]),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 6.h, horizontal: 15.w),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tileData[index]['activityType'],
                                    style: context.textStyles.mRegular(),
                                  ),
                                  Text(
                                    '  ${convertSpeed(tileData[index]['value'], settings.speedUnit).toStringAsFixed(1)} ${tileData[index]['valueUnit']}', // Top Average Speed
                                    style: context.textStyles.sRegular(),
                                  )
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 30.w, top: 10.h),
                                child: index < 1
                                    ? Divider(
                                        height: 2.h,
                                        color: const Color(0xffB1B0B2),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: settings.darkTheme
                        ? Color(0xff1c1c1e)
                        : Color(0xffc6c6c6),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      height: 140.h,
                      child: SfCartesianChart(
                          // primaryXAxis: DateTimeAxis(),
                          primaryXAxis: DateTimeAxis(
                              majorGridLines: const MajorGridLines(width: 0),
                              minorGridLines: const MinorGridLines(width: 0),
                              intervalType: DateTimeIntervalType.auto,
                              isVisible: true),
                          primaryYAxis: NumericAxis(
                              majorGridLines: const MajorGridLines(width: 0),
                              minorGridLines: const MinorGridLines(width: 0),
                              isVisible: true),
                          series: <ChartSeries>[
                            LineSeries<geolocator.Position, DateTime>(
                              dataSource: widget.session.geoPositions!,
                              xValueMapper: (geolocator.Position position, _) =>
                                  position.timestamp,
                              yValueMapper: (geolocator.Position position, _) =>
                                  convertDistance(
                                      position.altitude -
                                          widget.session.geoPositions![0]
                                              .altitude,
                                      settings.elevationUnit),
                            )
                          ]),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 6.h, horizontal: 15.w),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Climb',
                                style: context.textStyles.mRegular(),
                              ),
                              Text(
                                '  ${convertDistance(widget.session.altitude, settings.elevationUnit).toStringAsFixed(1)} ${settings.elevationUnit == 'ft' ? 'feet' : "meters"}', // Top Average Speed
                                style: context.textStyles.sRegular(),
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              if (widget.session.note != null &&
                  widget.session.note!.isNotEmpty) ...[
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      8.h,
                    ),
                    border: Border.all(
                      color: settings.darkTheme
                          ? Color(0xff1c1c1e)
                          : Color(0xffc6c6c6),
                      width: 2,
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  // height: 150.h,
                  constraints: BoxConstraints(minHeight: 45.h),
                  width: double.maxFinite,
                  padding: EdgeInsets.all(10.sp),
                  child: Text(
                    widget.session.note!,
                    style: context.textStyles.mRegular(),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
              SizedBox(
                height: 20.h,
              ),
              InkWell(
                onTap: () async {
                  await HiveDatabaseServices()
                      .deleteSession(widget.session.sessionId);

                  List<PedometerSession> sessions =
                      await HiveDatabaseServices().getAllSessions();
                  Provider.of<PedoMeterSessionProvider>(context, listen: false)
                      .updatePedometerSessionList(sessions);
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      8.h,
                    ),
                    border: Border.all(
                      color: settings.darkTheme
                          ? Color(0xff1c1c1e)
                          : Color(0xffc6c6c6),
                      width: 2,
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  height: 50.h,
                  width: double.maxFinite,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Text(
                        'Delete Activity History',
                        style: context.textStyles
                            .mRegular()
                            .copyWith(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 80.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
