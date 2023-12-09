import 'dart:convert';
import 'dart:io';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as chart;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xl;
import 'package:syncfusion_officechart/officechart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/subscription_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/services/hive_database_services.dart';
import 'package:speedometer/core/styling/sizes.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/history/screens/session_details_screen.dart';
import 'package:speedometer/features/history/widgets/matching_activity_tiles.dart';
import 'package:speedometer/features/history/widgets/sessionActivity.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:speedometer/features/history/widgets/edit_bottomsheet.dart';
import 'package:speedometer/features/history/widgets/share_bottomsheet.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as chart;
import 'package:screenshot/screenshot.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<double> topMaxSpeedList = [];
  List<double> topAvgSpeedList = [];
  List<double> topDistanceList = [];
  List<double> topDurationList = [];
  PedometerSession? topMaxSpeedSession;
  PedometerSession? topAvgSpeedSession;
  PedometerSession? topDistanceSession;
  PedometerSession? topDurationSession;
  List matchingActivity = [];
  bool selectSessions = false;
  // List<int> selectedSessionsIndex = [];
  assignData() {
    final pedometerProvider =
        Provider.of<PedoMeterSessionProvider>(context, listen: false);
    final pedometerSessions = pedometerProvider.pedometerSessions;
    if (pedometerSessions.isNotEmpty) {
      topMaxSpeedSession = pedometerSessions[0];
      topAvgSpeedSession = pedometerSessions[0];
      topDistanceSession = pedometerSessions[0];
      topDurationSession = pedometerSessions[0];
      for (var pedometerSession in pedometerSessions) {
        if (topMaxSpeedSession!.maxSpeedInMS < pedometerSession.maxSpeedInMS) {
          topMaxSpeedSession = pedometerSession;
        }
        if (topDistanceSession!.distanceInMeters <
            pedometerSession.distanceInMeters) {
          topDistanceSession = pedometerSession;
        }
        if (topDurationSession!.sessionDuration <
            pedometerSession.sessionDuration) {
          topDurationSession = pedometerSession;
        }
        if (topAvgSpeedSession!.averageSpeedInMS <
            pedometerSession.averageSpeedInMS) {
          topAvgSpeedSession = pedometerSession;
        }
      }
    } else {
      topMaxSpeedList = [];
      topAvgSpeedList = [];
      topDistanceList = [];
      topDurationList = [];
      topMaxSpeedSession = null;
      topAvgSpeedSession = null;
      topDistanceSession = null;
      topDurationSession = null;
    }
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
  void initState() {
    assignData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var pedometerSessionProvider =
        Provider.of<PedoMeterSessionProvider>(context, listen: false);
    var settings = Provider.of<UnitsProvider>(context).settings;
    matchingActivity = [
      {
        'activityType': 'Top Max Speed',
        'icon': Icons.local_fire_department,
        'session': topMaxSpeedSession,
        'valueUnit': settings.speedUnit
      },
      {
        'activityType': 'Top Avg Speed',
        'icon': Icons.speed,
        'session': topAvgSpeedSession,
        'valueUnit': settings.speedUnit
      },
      {
        'activityType': 'Top Distance',
        'icon': Icons.straighten,
        'session': topDistanceSession,
        'valueUnit': settings.speedUnit == 'mph'
            ? 'miles'
            : settings.speedUnit == 'kmph'
                ? 'kilometers'
                : settings.speedUnit == "knots"
                    ? "knots"
                    : "meters"
      },
      {
        'activityType': 'Top Duration',
        'icon': Icons.watch_later_outlined,
        'session': topDurationSession,
        'valueUnit': 'minutes'
      },
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 40.h,
        actionsIconTheme: IconThemeData(fill: 1),
        actions: [
          InkWell(
            onTap: () {
              setState(() {
                selectSessions = !selectSessions;
              });
            },
            radius: 15,
            borderRadius: BorderRadius.circular(20),
            child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                width: 60.w,
                alignment: Alignment.center,
                child: Text(
                  selectSessions ? "Done" : "Select",
                  style: context.textStyles.mRegular().copyWith(
                      color: selectSessions
                          ? Colors.red
                          : Theme.of(context).colorScheme.onPrimary),
                )),
          ),
          SizedBox(
            width: 15.w,
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "History",
                style: context.textStyles.lMedium(),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(left: 15.w),
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
                      width: 2.sp),
                ),
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        if (matchingActivity[index]['session'] == null) {
                          return;
                        }
                        Navigator.of(context)
                            .push(PageRouteBuilder(
                          pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                              SessionDetailsScreen(
                                  session: matchingActivity[index]['session']),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = Offset(1.0, 0.0);
                            var end = Offset.zero;
                            var curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ))
                            .then((value) {
                          assignData();
                          setState(() {});
                        });
                      },
                      child: MatchingActivityTile(
                        activityType: matchingActivity[index]['activityType'],
                        icon: matchingActivity[index]['icon'],
                        tileIndex: index,
                        tilesLength: matchingActivity.length,
                        session: matchingActivity[index]['session'] ??
                            PedometerSession(
                                sessionId: 'null',
                                sessionTitle: 'null',
                                speedInMS: 0,
                                maxSpeedInMS: 0,
                                averageSpeedInMS: 0,
                                distanceInMeters: 0,
                                sessionDuration: Duration.zero),
                        valueUnit: matchingActivity[index]['valueUnit'],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              pedometerSessionProvider.pedometerSessions.isEmpty
                  ? Center(
                      child: Text(
                        "No Recorded History yet.",
                        style: context.textStyles.mRegular(),
                      ),
                    )
                  : Container(
                      // height: 290.h,
                      width: double.maxFinite,
                      padding: EdgeInsets.only(left: 15.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(8.r)),
                        border: Border.all(
                            color: settings.darkTheme == null
                                ? MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark
                                    ? Color(0xff1c1c1e)
                                    : Color(0xffc6c6c6)
                                : settings.darkTheme!
                                    ? Color(0xff1c1c1e)
                                    : Color(0xffc6c6c6),
                            width: 2.sp),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount:
                            pedometerSessionProvider.pedometerSessions.length,
                        itemBuilder: (__, index) {
                          return Slidable(
                            key: ValueKey(0),
                            endActionPane: ActionPane(
                              motion: DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    editBottomSheet(
                                      context,
                                      pedometerSessionProvider
                                          .pedometerSessions[index],
                                      () {
                                        setState(() {});
                                      },
                                    );
                                    setState(() {});
                                    // await HiveDatabaseServices().updateSession(index, updatedSession)
                                  },
                                  backgroundColor: Color(0xFFC6C6C6),
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit_note,
                                  padding: EdgeInsets.all(5.sp),
                                ),
                                SlidableAction(
                                  onPressed: (_) async {
                                    if (Provider.of<SubscriptionProvider>(
                                                context,
                                                listen: false)
                                            .status ==
                                        SubscriptionStatus.notSubscribed) {
                                      shareBottomSheet(
                                          context,
                                          pedometerSessionProvider
                                              .pedometerSessions[index]);
                                    } else {
                                      final directory =
                                          await getApplicationDocumentsDirectory();
                                      final file = File(
                                          '${directory.path}/${pedometerSessionProvider.pedometerSessions[index].sessionTitle.replaceAll('/', '')}.xlsx');

                                      final xl.Workbook workbook =
                                          xl.Workbook();
                                      final xl.Worksheet sheet =
                                          workbook.worksheets[0];

                                      // Merge and set text for title cell.
                                      final xl.Range titleCell =
                                          sheet.getRangeByName('A1:I1');
                                      sheet.getRangeByName('A1').setText(
                                          pedometerSessionProvider
                                              .pedometerSessions[index]
                                              .sessionTitle);
                                      titleCell.merge();
                                      titleCell.cellStyle.fontSize = 30;
                                      titleCell.rowHeight = 40;
                                      titleCell.cellStyle
                                        ..hAlign = xl.HAlignType.center
                                        ..fontName = "Avenir Black Oblique"
                                        ..bold = true;

                                      final typeValuePairs = [
                                        [
                                          'Duration',
                                          formatDuration(
                                              pedometerSessionProvider
                                                  .pedometerSessions[index]
                                                  .sessionDuration)
                                        ],
                                        [
                                          'Distance',
                                          "${convertDistance(pedometerSessionProvider.pedometerSessions[index].distanceInMeters, settings.speedUnit == "mph" ? "mi" : settings.speedUnit == "kmph" ? "km" : settings.speedUnit == "knots" ? "knots" : "m").toStringAsFixed(3)} ${settings.speedUnit == "mph" ? "Mi" : settings.speedUnit == "kmph" ? "Km" : settings.speedUnit == "knots" ? "Knots" : "Meters"}"
                                        ],
                                        [
                                          'Started',
                                          DateFormat('M-d-yy, h:mm:ss a')
                                              .format(pedometerSessionProvider
                                                  .pedometerSessions[index]
                                                  .startTime!)
                                        ],
                                        [
                                          'Ended',
                                          DateFormat('M-d-yy, h:mm:ss a')
                                              .format(pedometerSessionProvider
                                                  .pedometerSessions[index]
                                                  .endTime!)
                                        ],
                                        [
                                          'Max Speed',
                                          "${convertSpeed(pedometerSessionProvider.pedometerSessions[index].maxSpeedInMS, settings.speedUnit).toStringAsFixed(3)} ${settings.speedUnit == "mph" ? "MPH" : settings.speedUnit == "kmph" ? "KM/h" : settings.speedUnit == "knots" ? "Knots" : "M/S"}"
                                        ],
                                        [
                                          'Avg Speed',
                                          "${convertSpeed(pedometerSessionProvider.pedometerSessions[index].averageSpeedInMS, settings.speedUnit).toStringAsFixed(3)} ${settings.speedUnit == "mph" ? "MPH" : settings.speedUnit == "kmph" ? "KM/h" : settings.speedUnit == "knots" ? "Knots" : "M/S"}"
                                        ],
                                      ];

// Set type and value pairs in a column (A2 and below)
                                      for (var i = 0;
                                          i < typeValuePairs.length;
                                          i++) {
                                        final columnTypeStart =
                                            getExcelColumnName(1); // Column A
                                        final columnTypeEnd =
                                            getExcelColumnName(4); // Column D
                                        final columnValueStart =
                                            getExcelColumnName(6); // Column F
                                        final columnValueEnd =
                                            getExcelColumnName(9); // Column I
                                        final row =
                                            i + 3; // Start from the second row

                                        // Set type cell
                                        // sheet.getRangeByName('A$row:D$row').merge();
                                        sheet.getRangeByName('B$row:C$row')
                                          ..merge()
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center
                                          ..cellStyle.bold = true
                                          ..cellStyle.fontSize = 15
                                          ..cellStyle.fontName =
                                              "Avenir Black Oblique"
                                          ..rowHeight = 20
                                          ..setText(typeValuePairs[i][0]);

                                        // Set value cell
                                        // sheet.getRangeByName('E$row:H$row').merge();
                                        sheet.getRangeByName('E$row:F$row')
                                          ..merge()
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center
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
                                      for (var i = 0;
                                          i < dataHeaders.length;
                                          i++) {
                                        final column = getExcelColumnName(i);
                                        sheet.getRangeByName('${column}10')
                                          ..setText(dataHeaders[i])
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center
                                          ..cellStyle.vAlign =
                                              xl.VAlignType.center
                                          ..cellStyle.fontSize = 12
                                          ..cellStyle.bold = true
                                          ..cellStyle.fontName = "Arial"
                                          ..rowHeight = 30;
                                      }

// Add the data for each column (A9 to H9 and below) based on your geoPositions list
                                      var distance = 0.0;
                                      for (var i = 0;
                                          i <
                                              pedometerSessionProvider
                                                  .pedometerSessions[index]
                                                  .geoPositions!
                                                  .length;
                                          i++) {
                                        final position =
                                            pedometerSessionProvider
                                                .pedometerSessions[index]
                                                .geoPositions![i];
                                        if (i > 0) {
                                          double distanceInMeters =
                                              Geolocator.distanceBetween(
                                            pedometerSessionProvider
                                                .pedometerSessions[index]
                                                .geoPositions![i - 1]
                                                .latitude,
                                            pedometerSessionProvider
                                                .pedometerSessions[index]
                                                .geoPositions![i - 1]
                                                .longitude,
                                            pedometerSessionProvider
                                                .pedometerSessions[index]
                                                .geoPositions![i]
                                                .latitude,
                                            pedometerSessionProvider
                                                .pedometerSessions[index]
                                                .geoPositions![i]
                                                .longitude,
                                          );
                                          distance += convertDistance(
                                              distanceInMeters,
                                              settings.speedUnit == "mph"
                                                  ? "mi"
                                                  : settings.speedUnit == "kmph"
                                                      ? "km"
                                                      : settings.speedUnit ==
                                                              "knots"
                                                          ? "knots"
                                                          : "m");
                                        }

                                        // Adjust the indices and get the corresponding column letter for each data element
                                        final index2 = (i + 1).toString();
                                        final timeStamp = position.timestamp!;
                                        final duration = formatDuration(position
                                            .timestamp!
                                            .difference(pedometerSessionProvider
                                                .pedometerSessions[index]
                                                .geoPositions![0]
                                                .timestamp!)); // You'll need to calculate this properly
                                        final speed = convertSpeed(
                                            position.speed, settings.speedUnit);

                                        final altitude = convertDistance(
                                            position.altitude -
                                                pedometerSessionProvider
                                                    .pedometerSessions[index]
                                                    .geoPositions![0]
                                                    .altitude,
                                            settings.elevationUnit);
                                        // final distance = (i * 0.034);
                                        final latitude =
                                            position.latitude.toString();
                                        final longitude =
                                            position.longitude.toString();

                                        // Set data for each column
                                        sheet.getRangeByName('A${i + 11}')
                                          ..setText(index2)
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center
                                          ..cellStyle.fontName = "Arial"
                                          ..cellStyle.fontSize = 11;
                                        sheet.getRangeByName('B${i + 11}')
                                          ..setText(
                                              DateFormat('M-d-yy, h:mm:ss a')
                                                  .format(timeStamp))
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center
                                          ..cellStyle.fontName = "Arial"
                                          ..cellStyle.fontSize = 11;
                                        sheet.getRangeByName('C${i + 11}')
                                          ..setValue(duration)
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center
                                          ..cellStyle.fontName = "Arial"
                                          ..cellStyle.fontSize = 11;
                                        sheet.getRangeByName('D${i + 11}')
                                          ..setNumber(double.parse(
                                              speed.toStringAsFixed(2)))
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center
                                          ..cellStyle.fontName = "Arial"
                                          ..cellStyle.fontSize = 11;
                                        sheet.getRangeByName('E${i + 11}')
                                          ..setNumber(double.parse(
                                              altitude.toStringAsFixed(2)))
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center
                                          ..cellStyle.fontName = "Arial"
                                          ..cellStyle.fontSize = 11;
                                        sheet.getRangeByName('F${i + 11}')
                                          ..setNumber(double.parse(
                                              distance.toStringAsFixed(3)))
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center
                                          ..cellStyle.fontName = "Arial"
                                          ..cellStyle.fontSize = 11;
                                        sheet.getRangeByName('G${i + 11}')
                                          ..setText(latitude)
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center
                                          ..cellStyle.fontName = "Arial"
                                          ..cellStyle.fontSize = 11;
                                        sheet.getRangeByName('H${i + 11}')
                                          ..setText(longitude)
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center
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
                                              "A1:H${pedometerSessionProvider.pedometerSessions[index].geoPositions!.length + 10}")
                                          .cellStyle
                                          .borders
                                          .all
                                        ..colorRgb = Colors.black
                                        ..lineStyle = xl.LineStyle.thin;
                                      xl.Style globalStyle =
                                          workbook.styles.add('style');
//set all border line style.
                                      globalStyle.borders.all.lineStyle =
                                          xl.LineStyle.thick;
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
                                      final ChartCollection charts =
                                          ChartCollection(sheet);

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
                                          'C10:D${10 + pedometerSessionProvider.pedometerSessions[index].geoPositions!.length}');
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
                                      sheet.getRangeByName('AY10')
                                        ..setText("Duration");

                                      sheet.getRangeByName('AZ10')
                                        ..setText(
                                            "Altitude (${settings.elevationUnit})");
                                      for (var i = 0;
                                          i <
                                              pedometerSessionProvider
                                                  .pedometerSessions[index]
                                                  .geoPositions!
                                                  .length;
                                          i++) {
                                        sheet.getRangeByName('AY${i + 11}')
                                          ..setValue(formatDuration(
                                              pedometerSessionProvider
                                                  .pedometerSessions[index]
                                                  .geoPositions![i]
                                                  .timestamp!
                                                  .difference(
                                                      pedometerSessionProvider
                                                          .pedometerSessions[
                                                              index]
                                                          .geoPositions![0]
                                                          .timestamp!)))
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center;
                                        sheet.getRangeByName('AZ${i + 11}')
                                          ..setNumber(convertDistance(
                                              double.parse(
                                                  pedometerSessionProvider
                                                      .pedometerSessions[index]
                                                      .geoPositions![i]
                                                      .altitude
                                                      .toStringAsFixed(2)),
                                              settings.elevationUnit))
                                          ..cellStyle.hAlign =
                                              xl.HAlignType.center;
                                      }
                                      chart2.dataRange = sheet.getRangeByName(
                                          "AY10:AZ${10 + pedometerSessionProvider.pedometerSessions[index].geoPositions!.length}");
                                      chart2.linePatternColor = '#0000FF';
                                      sheet.charts = charts;

                                      final List<int> excelBytes =
                                          workbook.saveAsStream().toList();
                                      await file.writeAsBytes(excelBytes);
                                      final newbytes = workbook.saveAsStream();

                                      File(file.path)
                                          .writeAsBytesSync(newbytes);
                                      print(
                                          'Excel file with text and image created at: ${file.path}');

                                      Share.shareXFiles([XFile(file.path)]);
                                    }
                                  },

                                  backgroundColor: Color(0xFF00BF63),
                                  foregroundColor: Colors.white,
                                  icon: Icons.file_upload_outlined,
                                  padding: EdgeInsets.all(5.sp),

                                  // label: 'Save',
                                ),
                                SlidableAction(
                                  onPressed: (context) async {
                                    await HiveDatabaseServices().deleteSession(
                                        pedometerSessionProvider
                                            .pedometerSessions[index]
                                            .sessionId);

                                    List<PedometerSession> sessions =
                                        await HiveDatabaseServices()
                                            .getAllSessions();

                                    Provider.of<PedoMeterSessionProvider>(
                                            context,
                                            listen: false)
                                        .updatePedometerSessionList(sessions);

                                    setState(() {});
                                  },
                                  backgroundColor: Color(0xFFFF0000),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_outline,
                                  padding: EdgeInsets.all(5.sp),

                                  // label: 'Save',
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context)
                                    .push(PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      SessionDetailsScreen(
                                          session: pedometerSessionProvider
                                              .pedometerSessions[index]),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    var begin = Offset(1.0, 0.0);
                                    var end = Offset.zero;
                                    var curve = Curves.ease;
                                    var tween = Tween(begin: begin, end: end)
                                        .chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                ))
                                    .then((value) {
                                  assignData();
                                  setState(() {});
                                });
                              },
                              // child: widget,
                              child: SessionActivityTile(
                                  pedometerSession: pedometerSessionProvider
                                      .pedometerSessions[index],
                                  tileIndex: index,
                                  tilesLength: pedometerSessionProvider
                                      .pedometerSessions.length,
                                  showCheckBox: selectSessions,
                                  deleteSession: () async {
                                    await HiveDatabaseServices().deleteSession(
                                        pedometerSessionProvider
                                            .pedometerSessions[index]
                                            .sessionId);

                                    List<PedometerSession> sessions =
                                        await HiveDatabaseServices()
                                            .getAllSessions();
                                    Provider.of<PedoMeterSessionProvider>(
                                            context,
                                            listen: false)
                                        .updatePedometerSessionList(sessions);
                                    assignData();
                                    setState(() {});
                                  }
                                  // selectedSessions: selectedSessionsIndex,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
              SizedBox(
                height: 10.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
