import 'dart:io';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xl;
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/subscription_provider.dart';
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
import 'package:syncfusion_flutter_charts/charts.dart' as chart;
import 'package:screenshot/screenshot.dart';
import 'package:syncfusion_officechart/officechart.dart';

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
    {"Motorcycle": Icons.two_wheeler},
    {"Car": Icons.directions_car},
    {"Train": Icons.directions_train},
    {"Plane": Icons.flight},
    {"Ship": Icons.sailing},
  ];
  double durationInMinutes(Duration? duration) {
    if (duration == null) {
      return 0.0;
    }

    final seconds = duration.inSeconds;
    return seconds / 60.0;
  }

  String getExcelColumnName(int columnNumber) {
    final int firstChar = 'A'.codeUnitAt(0);
    final int alphabetSize = 26;

    String columnName = '';

    while (columnNumber >= 0) {
      int remainder = columnNumber % alphabetSize;
      columnName = String.fromCharCode(firstChar + remainder) + columnName;
      columnNumber = (columnNumber - remainder) ~/ alphabetSize - 1;
    }

    return columnName;
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    final hoursStr = hours.toString().padLeft(2, '0');
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');

    return '$hoursStr:$minutesStr:$secondsStr';
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
                : settings.speedUnit == "knots"
                    ? "knots"
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
        backgroundColor: Theme.of(context).colorScheme.background,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
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
            borderRadius: BorderRadius.circular(20),
            child: Icon(
              Icons.edit_note,
              size: 28.sp,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          InkWell(
            onTap: () async {
              if (Provider.of<SubscriptionProvider>(context, listen: false)
                      .status ==
                  SubscriptionStatus.notSubscribed) {
                shareBottomSheet(context, widget.session);
              } else {
                final directory = await getApplicationDocumentsDirectory();
                final file = File(
                    '${directory.path}/${widget.session.sessionTitle.replaceAll('/', '')}.xlsx');

                final xl.Workbook workbook = xl.Workbook();
                final xl.Worksheet sheet = workbook.worksheets[0];

                // Merge and set text for title cell.
                final xl.Range titleCell = sheet.getRangeByName('A1:I1');
                sheet.getRangeByName('A1').setText(widget.session.sessionTitle);
                titleCell.merge();
                titleCell.cellStyle.fontSize = 30;
                titleCell.rowHeight = 40;
                titleCell.cellStyle
                  ..hAlign = xl.HAlignType.center
                  ..fontName = "Avenir Black Oblique"
                  ..bold = true;

                final typeValuePairs = [
                  ['Duration', formatDuration(widget.session.sessionDuration)],
                  [
                    'Distance',
                    "${convertDistance(widget.session.distanceInMeters, settings.speedUnit == "mph" ? "mi" : settings.speedUnit == "kmph" ? "km" : settings.speedUnit == "knots" ? "knots" : "m").toStringAsFixed(3)} ${settings.speedUnit == "mph" ? "Mi" : settings.speedUnit == "kmph" ? "Km" : settings.speedUnit == "knots" ? "Knots" : "Meters"}"
                  ],
                  [
                    'Started',
                    DateFormat('M-d-yy, h:mm:ss a')
                        .format(widget.session.startTime!)
                  ],
                  [
                    'Ended',
                    DateFormat('M-d-yy, h:mm:ss a')
                        .format(widget.session.endTime!)
                  ],
                  [
                    'Max Speed',
                    "${convertSpeed(widget.session.maxSpeedInMS, settings.speedUnit).toStringAsFixed(3)} ${settings.speedUnit == "mph" ? "MPH" : settings.speedUnit == "kmph" ? "KM/h" : settings.speedUnit == "knots" ? "Knots" : "M/S"}"
                  ],
                  [
                    'Avg Speed',
                    "${convertSpeed(widget.session.averageSpeedInMS, settings.speedUnit).toStringAsFixed(3)} ${settings.speedUnit == "mph" ? "MPH" : settings.speedUnit == "kmph" ? "KM/h" : settings.speedUnit == "knots" ? "Knots" : "M/S"}"
                  ],
                ];

// Set type and value pairs in a column (A2 and below)
                for (var i = 0; i < typeValuePairs.length; i++) {
                  final columnTypeStart = getExcelColumnName(1); // Column A
                  final columnTypeEnd = getExcelColumnName(4); // Column D
                  final columnValueStart = getExcelColumnName(6); // Column F
                  final columnValueEnd = getExcelColumnName(9); // Column I
                  final row = i + 3; // Start from the second row

                  // Set type cell
                  // sheet.getRangeByName('A$row:D$row').merge();
                  sheet.getRangeByName('B$row:C$row')
                    ..merge()
                    ..cellStyle.hAlign = xl.HAlignType.center
                    ..cellStyle.bold = true
                    ..cellStyle.fontSize = 15
                    ..cellStyle.fontName = "Avenir Black Oblique"
                    ..rowHeight = 20
                    ..setText(typeValuePairs[i][0]);

                  // Set value cell
                  // sheet.getRangeByName('E$row:H$row').merge();
                  sheet.getRangeByName('E$row:F$row')
                    ..merge()
                    ..cellStyle.hAlign = xl.HAlignType.center
                    ..cellStyle.bold = true
                    ..cellStyle.fontSize = 15
                    ..rowHeight = 20
                    ..setText(typeValuePairs[i][1]);
                }
// Set the headers for the data columns
                final dataHeaders = [
                  'Index',
                  'Time',
                  'Duration',
                  'Speed${'\n'}(${settings.speedUnit})',
                  'Altitude${'\n'}(${settings.elevationUnit})',
                  'Distance${'\n'}(${settings.speedUnit == "mph" ? "Mi" : settings.speedUnit == "kmph" ? "Km" : settings.speedUnit == "knots" ? "Knots" : "Meters"})',
                  'Latitude\n(WGS84)',
                  'Longitude\n(WGS84)',
                ];

// Set the headers in the eighth row (A8 to H8)
                for (var i = 0; i < dataHeaders.length; i++) {
                  final column = getExcelColumnName(i);
                  sheet.getRangeByName('${column}10')
                    ..setText(dataHeaders[i])
                    ..cellStyle.hAlign = xl.HAlignType.center
                    ..cellStyle.vAlign = xl.VAlignType.center
                    ..cellStyle.fontSize = 12
                    ..cellStyle.bold = true
                    ..cellStyle.fontName = "Arial"
                    ..rowHeight = 30;
                }

// Add the data for each column (A9 to H9 and below) based on your geoPositions list
                var distance = 0.0;
                for (var i = 0; i < widget.session.geoPositions!.length; i++) {
                  final position = widget.session.geoPositions![i];
                  if (i > 0) {
                    double distanceInMeters = Geolocator.distanceBetween(
                      widget.session.geoPositions![i - 1].latitude,
                      widget.session.geoPositions![i - 1].longitude,
                      widget.session.geoPositions![i].latitude,
                      widget.session.geoPositions![i].longitude,
                    );
                    distance += convertDistance(
                        distanceInMeters,
                        settings.speedUnit == "mph"
                            ? "mi"
                            : settings.speedUnit == "kmph"
                                ? "km"
                                : settings.speedUnit == "knots"
                                    ? "knots"
                                    : "m");
                  }

                  // Adjust the indices and get the corresponding column letter for each data element
                  final index2 = (i + 1).toString();
                  final timeStamp = position.timestamp!;
                  final duration = formatDuration(position.timestamp!
                      .difference(widget.session.geoPositions![0]
                          .timestamp!)); // You'll need to calculate this properly
                  final speed =
                      convertSpeed(position.speed, settings.speedUnit);

                  final altitude = convertDistance(
                      position.altitude -
                          widget.session.geoPositions![0].altitude,
                      settings.elevationUnit);
                  // final distance = (i * 0.034);
                  final latitude = position.latitude.toString();
                  final longitude = position.longitude.toString();

                  // Set data for each column
                  sheet.getRangeByName('A${i + 11}')
                    ..setText(index2)
                    ..cellStyle.hAlign = xl.HAlignType.center
                    ..cellStyle.fontName = "Arial"
                    ..cellStyle.fontSize = 11;
                  sheet.getRangeByName('B${i + 11}')
                    ..setText(DateFormat('M-d-yy, h:mm:ss a').format(timeStamp))
                    ..cellStyle.hAlign = xl.HAlignType.center
                    ..cellStyle.fontName = "Arial"
                    ..cellStyle.fontSize = 11;
                  sheet.getRangeByName('C${i + 11}')
                    ..setValue(duration)
                    ..cellStyle.hAlign = xl.HAlignType.center
                    ..cellStyle.fontName = "Arial"
                    ..cellStyle.fontSize = 11;
                  sheet.getRangeByName('D${i + 11}')
                    ..setNumber(double.parse(speed.toStringAsFixed(2)))
                    ..cellStyle.hAlign = xl.HAlignType.center
                    ..cellStyle.fontName = "Arial"
                    ..cellStyle.fontSize = 11;
                  sheet.getRangeByName('E${i + 11}')
                    ..setNumber(double.parse(altitude.toStringAsFixed(2)))
                    ..cellStyle.hAlign = xl.HAlignType.center
                    ..cellStyle.fontName = "Arial"
                    ..cellStyle.fontSize = 11;
                  sheet.getRangeByName('F${i + 11}')
                    ..setNumber(double.parse(distance.toStringAsFixed(3)))
                    ..cellStyle.hAlign = xl.HAlignType.center
                    ..cellStyle.fontName = "Arial"
                    ..cellStyle.fontSize = 11;
                  sheet.getRangeByName('G${i + 11}')
                    ..setText(latitude)
                    ..cellStyle.hAlign = xl.HAlignType.center
                    ..cellStyle.fontName = "Arial"
                    ..cellStyle.fontSize = 11;
                  sheet.getRangeByName('H${i + 11}')
                    ..setText(longitude)
                    ..cellStyle.hAlign = xl.HAlignType.center
                    ..cellStyle.fontName = "Arial"
                    ..cellStyle.fontSize = 11;
                  // Align them
                }
                for (var i = 1; i <= 100; i++) {
                  sheet.autoFitColumn(i);
                  // sheet.get
                }
                sheet
                    .getRangeByName(
                        "A1:H${widget.session.geoPositions!.length + 10}")
                    .cellStyle
                    .borders
                    .all
                  ..colorRgb = Colors.black
                  ..lineStyle = xl.LineStyle.thin;
                xl.Style globalStyle = workbook.styles.add('style');
//set all border line style.
                globalStyle.borders.all.lineStyle = xl.LineStyle.thick;
//set border color by hexa decimal.
                globalStyle.borders.all.color = '#9954CC';
                sheet.setColumnWidthInPixels(1, 90);
                sheet.setColumnWidthInPixels(2, 200);
                sheet.setColumnWidthInPixels(4, 110);
                sheet.setColumnWidthInPixels(5, 110);
                sheet.setColumnWidthInPixels(6, 120);
                sheet.setColumnWidthInPixels(7, 130);
                sheet.setColumnWidthInPixels(8, 130);
                // Create an instances of chart collection.
                final ChartCollection charts = ChartCollection(sheet);

// Add the chart.
                final Chart chart1 = charts.add();

// Set Chart Type.
                chart1.chartType = ExcelChartType.line;
                chart1.topRow = 10;
                chart1.leftColumn = 12;
                chart1.rightColumn = 23;
                chart1.bottomRow = 23;
                chart1.isSeriesInRows = false;
// Set data range in the worksheet.

                chart1.dataRange = sheet.getRangeByName(
                    'C10:D${10 + widget.session.geoPositions!.length}');
// set charts to worksheet.
                chart1.linePatternColor = '#0000FF';
                chart1.chartTitle = "Speed";
// Add the chart.
                final Chart chart2 = charts.add();

// Set Chart Type.
                chart2.chartType = ExcelChartType.line;
                chart2.topRow = 25;
                chart2.leftColumn = 12;
                chart2.rightColumn = 23;
                chart2.bottomRow = 38;
                chart2.isSeriesInRows = false;
                chart2.chartTitle = "Altitude";
// Set data range in the worksheet.
                sheet.getRangeByName('AY10')..setText("Duration");

                sheet.getRangeByName('AZ10')
                  ..setText("Altitude (${settings.elevationUnit})");
                for (var i = 0; i < widget.session.geoPositions!.length; i++) {
                  sheet.getRangeByName('AY${i + 11}')
                    ..setValue(formatDuration(
                        widget.session.geoPositions![i].timestamp!.difference(
                            widget.session.geoPositions![0].timestamp!)))
                    ..cellStyle.hAlign = xl.HAlignType.center;
                  sheet.getRangeByName('AZ${i + 11}')
                    ..setNumber(convertDistance(
                        double.parse(widget.session.geoPositions![i].altitude
                            .toStringAsFixed(2)),
                        settings.elevationUnit))
                    ..cellStyle.hAlign = xl.HAlignType.center;
                }
                chart2.dataRange = sheet.getRangeByName(
                    "AY10:AZ${10 + widget.session.geoPositions!.length}");
                chart2.linePatternColor = '#0000FF';
                sheet.charts = charts;

                final List<int> excelBytes = workbook.saveAsStream().toList();
                await file.writeAsBytes(excelBytes);
                final newbytes = workbook.saveAsStream();

                File(file.path).writeAsBytesSync(newbytes);
                print(
                    'Excel file with text and image created at: ${file.path}');

                Share.shareXFiles([XFile(file.path)]);
              }
            },
            borderRadius: BorderRadius.circular(20),
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
                    color: settings.darkTheme == null
                        ? MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Color(0xff1c1c1e)
                            : Color(0xffc6c6c6)
                        : settings.darkTheme!
                            ? Color(0xff1c1c1e)
                            : Color(0xffc6c6c6),
                    width: 2,
                  ),
                ),
                // height: 433.h,
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
                    Platform.isIOS
                        ? Container(
                            height: 180.h,
                            width: double.maxFinite,
                            child: AppleMap(
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      widget.session.path!.points.isEmpty
                                          ? widget.session.startPoint!.latitude
                                          : widget.session.path!.points.first
                                              .latitude,
                                      widget.session.path!.points.isEmpty
                                          ? widget.session.startPoint!.longitude
                                          : widget.session.path!.points.first
                                              .longitude),
                                  zoom: widget.session.distanceInMeters <= 1400
                                      ? 14
                                      : 12),
                              zoomGesturesEnabled: true,
                              gestureRecognizers:
                                  <Factory<OneSequenceGestureRecognizer>>[
                                new Factory<OneSequenceGestureRecognizer>(
                                  () => new EagerGestureRecognizer(),
                                ),
                              ].toSet(),
                              mapType: MapType.standard,
                              scrollGesturesEnabled: true,
                              annotations: widget.session.path!.points.isEmpty
                                  ? null
                                  : (Set()
                                    ..add(
                                      Annotation(
                                          annotationId: AnnotationId('start'),
                                          position: LatLng(
                                              widget.session.path!.points.first
                                                  .latitude,
                                              widget.session.path!.points.first
                                                  .longitude),
                                          icon: BitmapDescriptor
                                              .markerAnnotation),
                                    )
                                    ..add(
                                      Annotation(
                                          annotationId: AnnotationId('end'),
                                          position: LatLng(
                                              widget.session.path!.points.last
                                                  .latitude,
                                              widget.session.path!.points.last
                                                  .longitude),
                                          icon: BitmapDescriptor
                                              .markerAnnotation),
                                    )),
                              polylines: widget.session.path!.points.isEmpty
                                  ? null
                                  : Set<Polyline>.of([
                                      Polyline(
                                        polylineId: PolylineId(widget
                                            .session.path!.polylineId.value),
                                        // color: widget.session.path!.color,
                                        color: Colors.blue,
                                        points: List<LatLng>.from(
                                          widget.session.path!.points.map(
                                            (e) =>
                                                LatLng(e.latitude, e.longitude),
                                          ),
                                        ),
                                        width: 3,
                                      ),
                                    ]),
                            ),
                          )
                        : Image.asset(
                            'assets/images/map.png',
                            height: 180.h,
                            width: double.maxFinite,
                            fit: BoxFit.cover,
                          ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Container(
                      height: 190.h,
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5.h, horizontal: 15.w),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                              ? '  ${convertDistance(tileData[index]['value'], settings.speedUnit == 'mph' ? 'mi' : settings.speedUnit == 'kmph' ? 'km' : settings.speedUnit == "knots" ? "knots" : 'm').toStringAsFixed(1)} ${tileData[index]['valueUnit']}'
                                              : tileData[index]
                                                          ['activityType'] ==
                                                      'Max Speed'
                                                  ? '  ${convertSpeed(tileData[index]['value'], settings.speedUnit).toStringAsFixed(1)} ${tileData[index]['valueUnit']}'
                                                  : '  ${convertSpeed(tileData[index]['value'], settings.speedUnit).toStringAsFixed(1)} ${tileData[index]['valueUnit']}', // Top Average Speed
                                      style: context.textStyles.sRegular(),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 30.w, top: 10.h),
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
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
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
                      color: settings.darkTheme == null
                          ? MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Color(0xff1c1c1e)
                              : Color(0xffc6c6c6)
                          : settings.darkTheme!
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
                height: 10.h,
              ),
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
                    width: 2,
                  ),
                ),
                // height: 245.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Container(
                      height: 140.h,
                      child: SfCartesianChart(
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
                    Container(
                      height: 80.h,
                      child: ListView.builder(
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
                                  padding:
                                      EdgeInsets.only(left: 30.w, top: 10.h),
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
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
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
                    width: 2,
                  ),
                ),
                // height: 191.h,
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
                                'Max Elevation',
                                style: context.textStyles.mRegular(),
                              ),
                              Text(
                                '  ${convertDistance(widget.session.geoPositions!.reduce((current, next) => current.altitude > next.altitude ? current : next).altitude - widget.session.geoPositions!.first.altitude, settings.elevationUnit).toStringAsFixed(1)} ${settings.elevationUnit == 'ft' ? 'feet' : "meters"}', // Top Average Speed
                                style: context.textStyles.sRegular(),
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 30.w, top: 10.h, bottom: 10.h),
                            child: Divider(
                              height: 2.h,
                              color: const Color(0xffB1B0B2),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Avg Elevation',
                                style: context.textStyles.mRegular(),
                              ),
                              Text(
                                '  ${convertDistance(widget.session.geoPositions!.fold(0.0, (previousValue, element) => previousValue + (element.altitude - widget.session.geoPositions!.first.altitude)) / widget.session.geoPositions!.length, settings.elevationUnit).toStringAsFixed(1)} ${settings.elevationUnit == 'ft' ? 'feet' : "meters"}',
                                style: context.textStyles.sRegular(),
                              )
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 30.w, top: 10.h, bottom: 10.h),
                            child: Divider(
                              height: 2.h,
                              color: const Color(0xffB1B0B2),
                            ),
                          ),
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
                  height: 10.h,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      8.h,
                    ),
                    border: Border.all(
                      color: settings.darkTheme == null
                          ? MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Color(0xff1c1c1e)
                              : Color(0xffc6c6c6)
                          : settings.darkTheme!
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
                height: 10.h,
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
                      color: settings.darkTheme == null
                          ? MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Color(0xff1c1c1e)
                              : Color(0xffc6c6c6)
                          : settings.darkTheme!
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
