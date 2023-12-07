import 'package:intl/intl.dart';

String formattedDateTime() {
  DateTime now = DateTime.now();
  var formatter = DateFormat('MM-dd-yy HH:mm');
  String formatted = formatter.format(now);
  return formatted;
}
