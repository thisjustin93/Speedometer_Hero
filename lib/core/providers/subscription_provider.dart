import 'package:flutter/material.dart';

enum SubscriptionStatus {
  subscribed,
  notSubscribed,
}

class SubscriptionProvider with ChangeNotifier {
  SubscriptionStatus _status = SubscriptionStatus.notSubscribed;

  SubscriptionStatus get status => _status;
  void setSubscriptionStatus(SubscriptionStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
