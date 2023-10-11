import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/utils/app_snackbar.dart';

class HiveDatabaseServices {
  late Box<PedometerSession> _sessionBox;

  // Future<void> init() async {
  //   final appDocumentDir = await getApplicationDocumentsDirectory();
  //   Hive.init(appDocumentDir.path);
  //   Hive.registerAdapter(PedometerSessionAdapter());
  //   _sessionBox = await Hive.openBox<PedometerSession>('sessions');
  // }

  Future<void> addSession(
      PedometerSession session, BuildContext context) async {
    try {
      _sessionBox = await Hive.openBox<PedometerSession>('sessions');
      await _sessionBox.add(session);
      print(_sessionBox.values.length);
    } catch (e) {
      print(e.toString());
      showErrorMessage(
          context, errorSnackbar(content: e.toString(), context: context));
    }
  }

  Future<List<PedometerSession>> getAllSessions() async {
    _sessionBox = await Hive.openBox<PedometerSession>('sessions');

    List<PedometerSession> sessions = _sessionBox.values.toList();
    return sessions;
  }

  Future<void> updateSession(int index, PedometerSession updatedSession) async {
    await _sessionBox.putAt(index, updatedSession);
  }

  Future<void> deleteSession(int index) async {
    await _sessionBox.deleteAt(index);
  }

  Future<void> closeBox() async {
    await _sessionBox.close();
  }
}
