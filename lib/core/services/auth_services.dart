import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:speedometer/core/models/UserModel.dart';
import 'package:speedometer/core/services/firebase_services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel _userFromFirebaseUser(User? user) {
    return user != null
        ? UserModel(userId: user.uid)
        : UserModel(userId: '0');
  }

  Stream<UserModel>? get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userDoc = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userDoc.user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  // register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password,
      String username,  BuildContext context) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await FirebaseServices().creatUser(
        result.user!.uid,
        username,
        email,
        password,

      );

      return result.user!;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          width: 300.w,
          backgroundColor: const Color(0xff0BDD64),
          content: Center(
            child: Text(
              error.toString(),
            ),
          ),
        ),
      );
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      return null;
    }
  }
}

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.create(recursive: true);
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}
