import 'package:flutter/material.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';

class PedoMeterSessionProvider extends ChangeNotifier {
  List<PedometerSession> pedometerSessions = [];
  PedometerSession? currentPedometerSession;

  void setCurrentPedometerSession(PedometerSession pedometerSession) {
    currentPedometerSession = pedometerSession;
    notifyListeners();
  }

  void updatePedometerSessionList(List<PedometerSession> pedometerSessions) {
    this.pedometerSessions = pedometerSessions;
    this.pedometerSessions = this.pedometerSessions.reversed.toList();
    notifyListeners();
  }
}
