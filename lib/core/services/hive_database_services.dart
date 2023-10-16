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
      await _sessionBox.put(session.sessionId,session);
      print(_sessionBox.values.length);
      showErrorMessage(
          context,
          successSnackbar(
              content: "Session successfully added", context: context));
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

  Future<void> updateSession(String key, PedometerSession updatedSession) async {
    _sessionBox = await Hive.openBox<PedometerSession>('sessions');

    await _sessionBox.put(key, updatedSession);
  }

  Future<void> deleteSession(String key) async {
    _sessionBox = await Hive.openBox<PedometerSession>('sessions');

    await _sessionBox.delete(key);
  }

  Future<void> closeBox() async {
    await _sessionBox.close();
  }
}
