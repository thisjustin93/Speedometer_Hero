import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/models/UserModel.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/providers/user_provider.dart';
import 'package:speedometer/core/services/firebase_services.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/core/utils/media_query.dart';
import 'package:speedometer/core/utils/triangle_shape.dart';
import 'package:speedometer/features/Auth/signin_screen.dart';
import 'package:speedometer/features/Auth/signup_screen.dart';
import 'package:speedometer/main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int authType = 0;

  Future<bool> getInfo() async {
    bool? isLoged =
        await Provider.of<UserProvider>(context, listen: false).isUserLoged();
    if (isLoged == null) {
      isLoged = false;
    }
    FlutterNativeSplash.remove();
    await Future.delayed(Duration(milliseconds: 500));
    return isLoged;
  }

  Future<UserModel?> setUser() async {
    var uid =
        await Provider.of<UserProvider>(context, listen: false).getPrefUserId();
    UserModel? user = await FirebaseServices().singleUser(uid!);

    Provider.of<UserProvider>(context, listen: false).setUser(user!);
    return user;
  }

  bool isFocused = false;
  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<UnitsProvider>(context).settings;
    return FutureBuilder(
      future: getInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xff0BDD64),
            ),
          );
        } else if (snapshot.data == false) {
          return Scaffold(
            backgroundColor: settings.darkTheme == null
                ? MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Colors.black
                    : Colors.white
                : settings.darkTheme!
                    ? Colors.black
                    : Colors.white,
            body: Container(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 170.h,
                      width: 170.h,
                    ),
                    SizedBox(
                      height: 40.h,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              authType = 0;
                            });
                          },
                          child: SizedBox(
                            width: 120.w,
                            child: Column(
                              children: [
                                Text(
                                  'Sign in',
                                  style: context.textStyles.mThick(),
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                CustomPaint(
                                  painter: TrianglePainter(
                                    strokeColor: authType == 0
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    strokeWidth: 10.w,
                                    paintingStyle: PaintingStyle.fill,
                                  ),
                                  child: Container(
                                    height: 7.h,
                                    width: 13.w,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              authType = 1;
                            });
                          },
                          child: SizedBox(
                            width: 120.w,
                            child: Column(
                              children: [
                                Text(
                                  'Sign up',
                                  style: context.textStyles.mThick(),
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                CustomPaint(
                                  painter: TrianglePainter(
                                    strokeColor: authType == 1
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    strokeWidth: 10.w,
                                    paintingStyle: PaintingStyle.fill,
                                  ),
                                  child: Container(
                                    height: 7.h,
                                    width: 13.w,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: authType == 0,
                      child: Container(
                        width: context.width,
                        height: 305.h,
                        padding: EdgeInsets.symmetric(
                            vertical: 20.h, horizontal: 15.w),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.r))),
                        child: SignInScreen(
                          onFocusChanged: (bool value) {
                            setState(() {
                              isFocused = value;
                            });
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: authType == 1,
                      child: Container(
                        width: context.width,
                        height: 305.h,
                        padding: EdgeInsets.symmetric(
                            vertical: 20.h, horizontal: 15.w),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10.r))),
                        child: SignUpScreen(
                          onFocusChanged: (bool value) {
                            setState(() {
                              isFocused = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return FutureBuilder(
            future: setUser(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff0BDD64),
                  ),
                );
              } else {
                return MainNavigationScreen();
              }
            },
          );
        }
      },
    );
  }
}
