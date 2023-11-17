import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speedometer/core/models/UserModel.dart';

class UserProvider with ChangeNotifier {
  UserModel? user;
  void setPrefEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    notifyListeners();
  }

  void setPrefUserId(String uid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', uid);
    notifyListeners();
  }

  void userIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoged', true);
    notifyListeners();
  }

  void userOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoged', false);
    notifyListeners();
  }

  Future<bool?> isUserLoged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    return prefs.getBool('isLoged');
  }

  Future<String?> getPrefEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    return prefs.getString('email');
  }

  Future<String?> getPrefUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    notifyListeners();
    return prefs.getString('uid');
  }

  setUser(UserModel user) {
    this.user = user;
    notifyListeners();
  }
}
