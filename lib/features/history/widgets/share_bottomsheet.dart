import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:davinci/core/davinci_capture.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/convert_distance.dart';
import 'package:speedometer/core/utils/convert_speed.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:image/image.dart' as image;
import 'package:syncfusion_flutter_charts/charts.dart' as chart;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xl;
import 'package:syncfusion_officechart/officechart.dart';
import 'package:intl/intl.dart';

// import 'helper/save_file_mobile.dart'
//     if (dart.library.html) 'helper/save_file_web.dart';
shareBottomSheet(BuildContext context, PedometerSession session) async {
  var settings = Provider.of<UnitsProvider>(context, listen: false).settings;
  late GlobalKey<chart.SfCartesianChartState> _cartesianChartKey = GlobalKey();

  // await Navigator.of(context).push<dynamic>(
  //   MaterialPageRoute<dynamic>(
  //     builder: (BuildContext context) {
  //       return Scaffold(body: Image.memory(imageBytes));
  //     },
  //   ),
  // );
  final chartkey = GlobalKey();
  // Create a chart image
  final controller = ScreenshotController();
  // var bytes = await controller.captureFromWidget(
  //     context: context,
  //    );
  // Widget generateChartImage(List<Position>? positions, GlobalKey key) {
  //   return chart.SfCartesianChart(
  //     key: key,
  //     primaryXAxis: chart.DateTimeAxis(
  //       majorGridLines: const chart.MajorGridLines(width: 0),
  //       minorGridLines: const chart.MinorGridLines(width: 0),
  //       isVisible: true,
  //     ),
  //     primaryYAxis: chart.NumericAxis(
  //       majorGridLines: const chart.MajorGridLines(width: 0),
  //       minorGridLines: const chart.MinorGridLines(width: 0),
  //       isVisible: true,
  //     ),
  //     series: <chart.ChartSeries>[
  //       chart.LineSeries<Position, DateTime>(
  //         dataSource: positions ?? [], // Use provided positions data
  //         xValueMapper: (Position position, _) => position.timestamp,
  //         yValueMapper: (Position position, _) =>
  //             convertSpeed(position.speed, settings.speedUnit),
  //       )
  //     ],
  //   );
  // }

  // Future<Uint8List> createImageFromWidget(Widget widget, GlobalKey key) async {
  //   // final key = GlobalKey();
  //   final binding =
  //       WidgetsFlutterBinding.ensureInitialized() as WidgetsFlutterBinding;
  //   final renderObject =
  //       key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //   final image =
  //       await renderObject.toImage(pixelRatio: binding.window.devicePixelRatio);
  //   final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   final buffer = byteData!.buffer.asUint8List();
  //   return buffer;
  // }
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

  void setMainDetail(
      xl.Worksheet sheet, String range, int index, String type, String value) {
    final xl.Range typeCell = sheet.getRangeByName('A$index:D$index');
    typeCell.merge();
    sheet.getRangeByName('A$index').setText(type);
    typeCell.cellStyle.fontSize = 14;
    typeCell.cellStyle.bold = true;
    typeCell.cellStyle.hAlign = xl.HAlignType.center;
    final xl.Range valueCell = sheet.getRangeByName('E$index:H$index');
    valueCell.merge();
    valueCell.setText(value);
    valueCell.cellStyle.fontSize = 14;
  }

  return showDialog(
      context: context,
      builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            titlePadding: EdgeInsets.only(top: 10.h),
            contentPadding: EdgeInsets.zero,
            insetPadding:
                EdgeInsets.symmetric(horizontal: 13.w, vertical: 200.h),
            title: Container(
              alignment: Alignment.center,
              height: 50.sp,
              width: 50.sp,
              decoration: BoxDecoration(
                  color: Color(0xffF82929), shape: BoxShape.circle),
              child: Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 30.sp,
              ),
            ),
            content: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Column(
                children: [
                  Text(
                    'Buy the premium version of Speedometer GPSto unlock the full experienceincl. no ads, unlimited activity history & ability to exp data',
                    textAlign: TextAlign.center,
                    style: context.textStyles.mRegular(),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  // Container(
                  //   height: 80,
                  //   width: 120,
                  //   child: chart.SfCartesianChart(
                  //     key: _cartesianChartKey,
                  //     primaryXAxis: chart.DateTimeAxis(
                  //       majorGridLines: chart.MajorGridLines(width: 0),
                  //       minorGridLines: chart.MinorGridLines(width: 0),
                  //       isVisible: true,
                  //     ),
                  //     primaryYAxis: chart.NumericAxis(
                  //       majorGridLines: chart.MajorGridLines(width: 0),
                  //       minorGridLines: chart.MinorGridLines(width: 0),
                  //       isVisible: true,
                  //     ),
                  //     series: <chart.ChartSeries>[
                  //       chart.LineSeries<Position, DateTime>(
                  //         // markerSettings: chart.MarkerSettings(width: 1),
                  //         // dataLabelSettings: chart.DataLabelSettings(
                  //         //     textStyle:
                  //         //         TextStyle(fontSize: 8.sp, color: Colors.red)),
                  //         dataSource: session.geoPositions ?? [],
                  //         xValueMapper: (Position position, _) =>
                  //             position.timestamp,
                  //         yValueMapper: (Position position, _) =>
                  //             convertSpeed(position.speed, settings.speedUnit),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () async {

                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //       backgroundColor: Color(0xffF82929),
                  //       foregroundColor: Colors.white,
                  //       fixedSize: Size(300.w, 40.h),
                  //       shape: StadiumBorder()),
                  //   child: Text(
                  //     'Export Data',
                  //     style: context.textStyles
                  //         .mThick()
                  //         .copyWith(color: Colors.white),
                  //   ),
                  // ),
                  ElevatedButton(
                    onPressed: () async {
                      final directory =
                          await getApplicationDocumentsDirectory();
                      final file = File(
                          '${directory.path}/${session.sessionTitle.replaceAll('/', '')}.xlsx');

                      final xl.Workbook workbook = xl.Workbook();
                      final xl.Worksheet sheet = workbook.worksheets[0];
                      // sheet.getRangeByName('A1').columnWidth = 4.82;
                      // sheet.getRangeByName('B1:C1').columnWidth = 13.82;
                      // sheet.getRangeByName('D1').columnWidth = 13.20;
                      // sheet.getRangeByName('E1').columnWidth = 7.50;
                      // sheet.getRangeByName('F1').columnWidth = 9.73;
                      // sheet.getRangeByName('G1').columnWidth = 8.82;
                      // sheet.getRangeByName('H1').columnWidth = 4.46;
// Set the title in a merged cell from A to H in the first row
                      // Set background color for title cell.
                      // sheet.getRangeByName('A1:Z100').cellStyle.backColor =
                      //     '#ffffff';
                      // sheet.getRangeByName('A1:H1').cellStyle.backColor =
                      //     '#333F4F';

                      // Merge and set text for title cell.
                      final xl.Range titleCell = sheet.getRangeByName('A1:I1');
                      sheet.getRangeByName('A1').setText(session.sessionTitle);
                      titleCell.merge();
                      titleCell.cellStyle.fontSize = 30;
                      titleCell.rowHeight = 40;
                      titleCell.cellStyle
                        ..hAlign = xl.HAlignType.center
                        // ..fontSize = 30
                        ..fontName = "Avenir Black Oblique"
                        ..bold = true;
                      // final xl.Range durationCell =
                      //     sheet.getRangeByName('A3:D3');
                      // // durationCell.merge();
                      // durationCell.cellStyle.fontSize = 10;
                      // durationCell.rowHeight = 18;
                      // durationCell.cellStyle.hAlign = xl.HAlignType.center;

                      // final xl.Range distanceCell =
                      //     sheet.getRangeByName('A4:D4');

                      // final xl.Range startedCell =
                      //     sheet.getRangeByName('A5:D5');
                      // // durationCell.autoFitRows();
                      // // durationCell.autoFitColumns();

                      // sheet.getRangeByName('A3').setText("Distance");

                      // sheet.getRangeByName('A2').setText("Duration");

                      // sheet.getRangeByName('A4').setText("Started");

                      // distanceCell.merge();
                      // durationCell.merge();
                      // startedCell.merge();
                      // for (var i = 0; i < distanceCell.cells.length; i++) {
                      //   print(distanceCell.cells[i].getText());
                      //   print(durationCell.cells[i].getText());
                      //   print(startedCell.cells[i].getText());
                      // }
                      // startedCell.cellStyle.hAlign = xl.HAlignType.center;
                      // startedCell.cellStyle.vAlign = xl.VAlignType.center;
                      // distanceCell.cellStyle.hAlign = xl.HAlignType.center;
                      // distanceCell.cellStyle.vAlign = xl.VAlignType.center;
                      // durationCell.cellStyle.hAlign = xl.HAlignType.center;
                      // durationCell.cellStyle.vAlign = xl.VAlignType.center;

                      // setMainDetail(sheet, 'A3:D3', 3, 'Duration',
                      //     formatDuration(session.sessionDuration));
                      // setMainDetail(sheet, 'A4:D4', 4, 'Distance',
                      //     '${convertDistance(session.distanceInMeters, 'km').toString()} km');
                      // setMainDetail(sheet, 'A5:D5', 5, 'Started',
                      //     session.startTime!.toIso8601String());
                      // setMainDetail(sheet, 'A6:D6', 6, 'Ended',
                      //     session.endTime!.toIso8601String());
                      // setMainDetail(sheet, 'A7:D7', 7, 'Max Speed',
                      //     '${convertSpeed(session.maxSpeedInMS, 'kmph').toString()} km/h');
                      // setMainDetail(sheet, 'A8:D8', 8, 'Avg Speed',
                      //     '${convertSpeed(session.averageSpeedInMS, 'kmph').toString()} km/h');
                      // sheet
                      //     .getRangeByName('A1:H1')
                      //     .setText(session.sessionTitle);
                      // sheet.getRangeByIndex(1, 1, 1, 9).merge();
                      // sheet.getRangeByIndex(1, 1, 1, 9).rowHeight = 30;
                      // sheet.getRangeByName('A1:H1').cellStyle
                      //   ..bold = true
                      //   ..fontSize =
                      //       13 // You can adjust the font size as needed
                      //   ..hAlign = xl.HAlignType.center
                      //   ..vAlign = xl.VAlignType.center
                      //   ..backColor = '#C0C0C0'; // Gray background

// Set type and value pairs for each of the 6 sections
// DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(timeStamp)
                      final typeValuePairs = [
                        ['Duration', formatDuration(session.sessionDuration)],
                        [
                          'Distance',
                          "${convertDistance(session.distanceInMeters, settings.speedUnit == "mph" ? "mi" : settings.speedUnit == "kmph" ? "km" : settings.speedUnit == "knots" ? "knots" : "m").toStringAsFixed(3)} ${settings.speedUnit == "mph" ? "Mi" : settings.speedUnit == "kmph" ? "Km" : settings.speedUnit == "knots" ? "Knots" : "Meters"}"
                        ],
                        [
                          'Started',
                          DateFormat('M/d/yy, h:mm:ss a')
                              .format(session.startTime!)
                        ],
                        [
                          'Ended',
                          DateFormat('M/d/yy, h:mm:ss a')
                              .format(session.endTime!)
                        ],
                        [
                          'Max Speed',
                          "${convertSpeed(session.maxSpeedInMS, settings.speedUnit).toStringAsFixed(3)} ${settings.speedUnit == "mph" ? "MPH" : settings.speedUnit == "kmph" ? "KM/h" : settings.speedUnit == "knots" ? "Knots" : "M/S"}"
                        ],
                        [
                          'Avg Speed',
                          "${convertSpeed(session.averageSpeedInMS, settings.speedUnit).toStringAsFixed(3)} ${settings.speedUnit == "mph" ? "MPH" : settings.speedUnit == "kmph" ? "KM/h" : settings.speedUnit == "knots" ? "Knots" : "M/S"}"
                        ],
                      ];

// Set type and value pairs in a column (A2 and below)
                      for (var i = 0; i < typeValuePairs.length; i++) {
                        final columnTypeStart =
                            getExcelColumnName(1); // Column A
                        final columnTypeEnd = getExcelColumnName(4); // Column D
                        final columnValueStart =
                            getExcelColumnName(6); // Column F
                        final columnValueEnd =
                            getExcelColumnName(9); // Column I
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
                        // To make it look like merged
                        // sheet.getRangeByName('A$row:D$row').merge();
                        // sheet.getRangeByName('E$row:H$row').merge();
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

                        //  sheet
                        // .getRangeByName('${column}10').cellStyle.hAlign=xl.HAlignType.center;
                      }

// Add the data for each column (A9 to H9 and below) based on your geoPositions list
                      var distance = 0.0;
                      for (var i = 0; i < session.geoPositions!.length; i++) {
                        final position = session.geoPositions![i];
                        if (i > 0) {
                          double distanceInMeters = Geolocator.distanceBetween(
                            session.geoPositions![i - 1].latitude,
                            session.geoPositions![i - 1].longitude,
                            session.geoPositions![i].latitude,
                            session.geoPositions![i].longitude,
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
                        final index = (i + 1).toString();
                        final timeStamp = position.timestamp!;
                        final duration = formatDuration(position.timestamp!
                            .difference(session.geoPositions![0]
                                .timestamp!)); // You'll need to calculate this properly
                        final speed =
                            convertSpeed(position.speed, settings.speedUnit);
                        // distance = convertDistance(
                        //     distance,
                        //     settings.speedUnit == "mph"
                        //         ? "mi"
                        //         : settings.speedUnit == "kmph"
                        //             ? "km"
                        //             : settings.speedUnit == "m"
                        //                 ? "m"
                        //                 : "knots");
                        final altitude = convertDistance(
                            position.altitude -
                                session.geoPositions![0].altitude,
                            settings.elevationUnit);
                        // final distance = (i * 0.034);
                        final latitude = position.latitude.toString();
                        final longitude = position.longitude.toString();

                        // Set data for each column
                        sheet.getRangeByName('A${i + 11}')
                          ..setText(index)
                          ..cellStyle.hAlign = xl.HAlignType.center
                          ..cellStyle.fontName = "Arial"
                          ..cellStyle.fontSize = 11;
                        print(timeStamp);
                        sheet.getRangeByName('B${i + 11}')
                          ..setText(
                              DateFormat('M/d/yy, h:mm:ss a').format(timeStamp))
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
                              "A1:H${session.geoPositions!.length + 10}")
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
                          'C10:D${10 + session.geoPositions!.length}');
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
                      for (var i = 0; i < session.geoPositions!.length; i++) {
                        sheet.getRangeByName('AY${i + 11}')
                          ..setValue(formatDuration(session
                              .geoPositions![i].timestamp!
                              .difference(session.geoPositions![0].timestamp!)))
                          ..cellStyle.hAlign = xl.HAlignType.center;
                        sheet.getRangeByName('AZ${i + 11}')
                          ..setNumber(convertDistance(
                              double.parse(session.geoPositions![i].altitude
                                  .toStringAsFixed(2)),
                              settings.elevationUnit))
                          ..cellStyle.hAlign = xl.HAlignType.center;
                      }
                      chart2.dataRange = sheet.getRangeByName(
                          "AY10:AZ${10 + session.geoPositions!.length}");
                      chart2.linePatternColor = '#0000FF';
                      sheet.charts = charts;

                      // sheet.deleteColumn(24);
                      // sheet.deleteColumn(25);
                      // sheet.getRangeByName('A1').setText('Session ID');
                      // sheet.getRangeByName('B1').setText('Session Title');
                      // sheet.getRangeByName('C1').setText('Start Time');
                      // sheet.getRangeByName('D1').setText('End Time');
                      // sheet.getRangeByName('E1').setText('Speed (m/s)');
                      // sheet.getRangeByName('F1').setText('Max Speed (m/s)');
                      // sheet.getRangeByName('G1').setText('Average Speed (m/s)');
                      // sheet.getRangeByName('H1').setText('Start Latitude');
                      // sheet.getRangeByName('I1').setText('Start Longitude');
                      // sheet.getRangeByName('J1').setText('End Latitude');
                      // sheet.getRangeByName('K1').setText('End Longitude');
                      // sheet.getRangeByName('L1').setText('Distance (Meters)');
                      // sheet.getRangeByName('M1').setText('Altitude');
                      // sheet.getRangeByName('N1').setText('Activity Type');
                      // sheet.getRangeByName('O1').setText('Note');

                      // final rowData = [
                      //   session.sessionId,
                      //   session.sessionTitle,
                      //   session.startTime?.toIso8601String(),
                      //   session.endTime?.toIso8601String(),
                      //   session.speedInMS,
                      //   session.maxSpeedInMS,
                      //   session.averageSpeedInMS,
                      //   session.startPoint?.latitude,
                      //   session.startPoint?.longitude,
                      //   session.endPoint?.latitude,
                      //   session.endPoint?.longitude,
                      //   session.distanceInMeters,
                      //   session.altitude,
                      //   session.activityType,
                      //   session.note,
                      // ];
                      // final columnNames = [
                      //   'A',
                      //   'B',
                      //   'C',
                      //   'D',
                      //   'E',
                      //   'F',
                      //   'G',
                      //   'H',
                      //   'I',
                      //   'J',
                      //   'K',
                      //   'L',
                      //   'M',
                      //   'N',
                      //   'O'
                      // ];
                      // for (var i = 0; i < rowData.length; i++) {
                      //   sheet
                      //       .getRangeByName('${columnNames[i]}2')
                      //       .setText(rowData[i].toString());
                      // }
                      // final ui.Image data = await _cartesianChartKey
                      //     .currentState!
                      //     .toImage(pixelRatio: 3.0);

                      // final ByteData? bytes =
                      //     await data.toByteData(format: ui.ImageByteFormat.png);
                      // final Uint8List imageBytes = bytes!.buffer.asUint8List(
                      //     bytes.offsetInBytes, bytes.lengthInBytes);
                      // final imageBase64 =
                      //     base64Encode(Uint8List.fromList(imageBytes!));

                      // final row = rowData.length +
                      //     2; // Choose the row where you want to insert the image
                      // sheet.getRangeByName('A$row').setText(imageBase64);
                      final List<int> excelBytes =
                          workbook.saveAsStream().toList();
                      // final File file = File(excelFilePath);
                      await file.writeAsBytes(excelBytes);
                      // final xl.Picture picture =
                      //     sheet.pictures.addStream(5, 10, imageBytes);
                      final newbytes = workbook.saveAsStream();

                      File(file.path).writeAsBytesSync(newbytes);
                      print(
                          'Excel file with text and image created at: ${file.path}');
                      // }
                      ///
                      Navigator.of(context).pop();
                      Share.shareXFiles([XFile(file.path)]);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffF82929),
                        foregroundColor: Colors.white,
                        fixedSize: Size(300.w, 40.h),
                        shape: StadiumBorder()),
                    child: Text(
                      'Export Data',
                      style: context.textStyles
                          .mThick()
                          .copyWith(color: Colors.white),
                    ),
                  ),

                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: context.textStyles.mRegular(),
                      )),
                ],
              ),
            ),
          ));
}

/// Creates an image from the given widget by first spinning up a element and render tree,
/// then waiting for the given [wait] amount of time and then creating an image via a [RepaintBoundary].
///
/// The final image will be of size [imageSize] and the the widget will be layout, ... with the given [logicalSize].
Future<Uint8List> createImageFromWidget(Widget widget,
    {required Duration wait,
    required Size logicalSize,
    required Size imageSize}) async {
  final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

  logicalSize ??= ui.window.physicalSize / ui.window.devicePixelRatio;
  imageSize ??= ui.window.physicalSize;

  assert(logicalSize.aspectRatio == imageSize.aspectRatio);

  final RenderView renderView = RenderView(
    view: ui.window,
    child: RenderPositionedBox(
        alignment: Alignment.center, child: repaintBoundary),
    configuration: ViewConfiguration(
      size: logicalSize,
      devicePixelRatio: 1.0,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  final PipelineOwner pipelineOwner = PipelineOwner();
  final BuildOwner buildOwner = BuildOwner();

  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final RenderObjectToWidgetElement<RenderBox> rootElement =
      RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: widget,
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);

  if (wait != null) {
    await Future.delayed(wait);
  }

  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();

  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final ui.Image image = await repaintBoundary.toImage(
      pixelRatio: imageSize.width / logicalSize.width);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

  return byteData!.buffer.asUint8List();
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
