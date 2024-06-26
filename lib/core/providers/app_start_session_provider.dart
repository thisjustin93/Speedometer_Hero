// Provider for the home and compass icon in navbar. when app is started, it will be home icon but if home icon is presses or a session is started then it will become a compass icon

import 'package:flutter/cupertino.dart';

class RecordingProvider extends ChangeNotifier {
  bool recordingStarted = false;
  startRecording() {
    recordingStarted = true;
    notifyListeners();
  }

  stopRecording() {
    recordingStarted = false;
    notifyListeners();
  }
}
