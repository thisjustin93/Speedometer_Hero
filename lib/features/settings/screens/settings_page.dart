import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speedometer/core/providers/subscription_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/providers/user_provider.dart';
import 'package:speedometer/core/services/firebase_services.dart';
import 'package:speedometer/core/services/payment_services.dart';
import 'package:speedometer/core/services/settigns_db_services.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/history/widgets/share_bottomsheet.dart';
import 'package:speedometer/features/settings/screens/change_elevationunit_screen.dart';
import 'package:speedometer/features/settings/screens/change_speedunit_screen.dart';
import 'package:speedometer/features/settings/screens/change_theme_screen.dart';
import 'package:speedometer/features/settings/widgets/switch_listtile_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class Unit {
  late String key;
  late String value;
  Unit({required this.key, required this.value});
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Unit> speedUnits = [
    Unit(key: 'mph', value: 'Miles Per Hour'),
    Unit(key: 'mps', value: 'Meters Per Second'),
    Unit(key: 'kmph', value: 'Kilometers Per Hour'),
    Unit(key: 'knots', value: 'Nautical Miles Per Hour'),
  ];
  List<Unit> elevationUnits = [
    Unit(key: 'ft', value: 'Feet'),
    Unit(key: 'm', value: 'Meters')
  ];
  List gaugeSpeeds = [10, 20, 50, 100, 200, 400, 800, 1600, 3200];
  @override
  Widget build(BuildContext context) {
    var settingProvider = Provider.of<UnitsProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 12.w, right: 12.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 30.h,
                  color: Colors.transparent,
                ),
                Text(
                  'Settings',
                  style: context.textStyles.lMedium(),
                ),
                SizedBox(
                  height: 5.h,
                ),
                if (Provider.of<SubscriptionProvider>(context, listen: false)
                        .status ==
                    SubscriptionStatus.notSubscribed)
                  Container(
                    height: 200.h,
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: settingProvider.settings.darkTheme == null
                              ? MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? Color(0xff1c1c1e)
                                  : Color(0xffc6c6c6)
                              : settingProvider.settings.darkTheme!
                                  ? Color(0xff1c1c1e)
                                  : Color(0xffc6c6c6),
                          width: 2.sp),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 5.h),
                          alignment: Alignment.center,
                          height: 40.sp,
                          width: 40.sp,
                          decoration: const BoxDecoration(
                              color: Color(0xffF82929), shape: BoxShape.circle),
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 30.sp,
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          'Buy the premium version of Speedometer GPSto unlock the full experienceincl. no ads, unlimited activity history & ability to exp data',
                          textAlign: TextAlign.center,
                          style: context.textStyles
                              .mRegular()
                              .copyWith(fontSize: 13.sp),
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        InkWell(
                          onTap: () async {
                            if (Provider.of<SubscriptionProvider>(context,
                                        listen: false)
                                    .status ==
                                SubscriptionStatus.notSubscribed) {
                              try {
                                await Purchases.purchasePackage(Package(
                                    "one_time_subscription",
                                    PackageType.lifetime,
                                    StoreProduct(
                                        "one_time_subscription",
                                        "Buy the premium version of Speedometer GPS to unlock the full experienceincl. no ads, unlimited activity history & ability to exp data",
                                        'Speedometer GPS Premium',
                                        4.99,
                                        "\$4.99",
                                        "USD"),
                                    "one_time_subscription"));
                                // var user = Provider.of<UserProvider>(context,
                                //         listen: false)
                                //     .user;
                                // final paymentDone = await StripePayment()
                                //     .makePayment("499"); //4.99
                                // if (paymentDone) {
                                //   user!.isUserSubscribed = true;
                                //   await FirebaseServices().updateUser(user);
                                //   Provider.of<SubscriptionProvider>(context,
                                //           listen: false)
                                //       .setSubscriptionStatus(
                                //           SubscriptionStatus.subscribed);
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     SnackBar(
                                //       content: Text(
                                //           "Congratulations. You are now a Premium user"),
                                //     ),
                                //   );
                                // } else {
                                //   ScaffoldMessenger.of(context).showSnackBar(
                                //     SnackBar(
                                //       content:
                                //           Text("Payment could not be proceed"),
                                //     ),
                                //   );
                                // }
                              } catch (e) {
                                print("error payment:$e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            height: 32.h,
                            width: 280.w,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(25.r)),
                            alignment: Alignment.center,
                            child: Text(
                              "Remove Ads",
                              style: context.textStyles.mRegular().copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  height: 10.h,
                ),
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.only(left: 20.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: settingProvider.settings.darkTheme == null
                            ? MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Color(0xff1c1c1e)
                                : Color(0xffc6c6c6)
                            : settingProvider.settings.darkTheme!
                                ? Color(0xff1c1c1e)
                                : Color(0xffc6c6c6),
                        width: 2.sp),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ChangeSpeedUnitScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ));
                        },
                        child: Container(
                          height: 50.h,
                          padding: EdgeInsets.only(top: 5.h),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Speed Unit',
                                      style: context.textStyles.mRegular(),
                                    ),
                                    Text(
                                      settingProvider.settings.speedUnit ==
                                              'mph'
                                          ? "Miles Per Hour"
                                          : settingProvider
                                                      .settings.speedUnit ==
                                                  'kmph'
                                              ? "Kilometers Per Hour"
                                              : settingProvider
                                                          .settings.speedUnit ==
                                                      'knots'
                                                  ? "Nautical Miles Per Hour"
                                                  : "Meters Per Second",
                                      style: context.textStyles.sRegular(),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 35.sp,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              // DropdownButton(
                              //   value: settingProvider.settings.speedUnit,
                              //   items: speedUnits
                              //       .map(
                              //         (unit) => DropdownMenuItem(
                              //           value: unit.key,
                              //           child: Text(
                              //             unit.key,
                              //             style: context.textStyles
                              //                 .sThick()
                              //                 .copyWith(color: Colors.red),
                              //           ),
                              //         ),
                              //       )
                              //       .toList(),
                              //   onChanged: (value) {
                              //     // settingProvider.settings.setSpeedUnit(value!);
                              //     settingProvider.settings.speedUnit = value!;
                              //     settingProvider
                              //         .setAllUnits(settingProvider.settings);
                              //     HiveSettingsDB()
                              //         .updateSettings(settingProvider.settings);
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ChangeElevationUnitScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              var begin = Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;
                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ));
                        },
                        child: Container(
                          height: 50.h,
                          padding: EdgeInsets.only(top: 5.h),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Elevation Unit',
                                      style: context.textStyles.mRegular(),
                                    ),
                                    Text(
                                      settingProvider.settings.elevationUnit,
                                      style: context.textStyles.sRegular(),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 35.sp,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              // DropdownButton(
                              //   value: settingProvider.settings.elevationUnit,
                              //   items: elevationUnits
                              //       .map(
                              //         (unit) => DropdownMenuItem(
                              //           value: unit.key,
                              //           child: Text(
                              //             unit.key,
                              //             style: context.textStyles
                              //                 .sThick()
                              //                 .copyWith(color: Colors.red),
                              //           ),
                              //         ),
                              //       )
                              //       .toList(),
                              //   onChanged: (value) {
                              //     settingProvider.settings.elevationUnit = value!;
                              //     settingProvider
                              //         .setAllUnits(settingProvider.settings);
                              //     HiveSettingsDB()
                              //         .updateSettings(settingProvider.settings);
                              //     // settingProvider.settings
                              //     //     .setElevationUnit(value!);
                              //   },
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SwithListTile(type: 'Show Compass'),
                      SwithListTile(type: 'Show Elevation'),
                      SwithListTile(type: 'Show City Name'),
                      Container(
                        height: 50.h,
                        padding: EdgeInsets.only(top: 5.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Maximum Gauge Speed',
                                    style: context.textStyles.mRegular(),
                                  ),
                                  Text(
                                    "${settingProvider.settings.maximumGaugeSpeed} ${settingProvider.settings.speedUnit}",
                                    style: context.textStyles.sRegular(),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                var index = gaugeSpeeds.indexWhere((element) =>
                                    element ==
                                    settingProvider.settings.maximumGaugeSpeed);
                                if (index != 0) {
                                  settingProvider.settings.maximumGaugeSpeed =
                                      gaugeSpeeds[index - 1];
                                }

                                settingProvider
                                    .setAllUnits(settingProvider.settings);
                                HiveSettingsDB()
                                    .updateSettings(settingProvider.settings);
                                // settingProvider.settings
                                //     .changeMaximumGaugeSpeed(false);
                              },
                              child: Icon(
                                Icons.remove_circle_outline,
                                color: Colors.grey,
                                size: 30.sp,
                              ),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            InkWell(
                              onTap: () {
                                var index = gaugeSpeeds.indexWhere((element) =>
                                    element ==
                                    settingProvider.settings.maximumGaugeSpeed);
                                if (index < gaugeSpeeds.length - 1) {
                                  settingProvider.settings.maximumGaugeSpeed =
                                      gaugeSpeeds[index + 1];
                                }
                                // settingProvider.settings.maximumGaugeSpeed += 1;
                                settingProvider
                                    .setAllUnits(settingProvider.settings);
                                HiveSettingsDB()
                                    .updateSettings(settingProvider.settings);
                                // settingProvider.settings
                                //     .changeMaximumGaugeSpeed(true);
                              },
                              child: Icon(
                                Icons.add_circle_outline_sharp,
                                color: Colors.grey,
                                size: 30.sp,
                              ),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ChangeAppThemeScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var begin = Offset(1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.ease;
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ));
                  },
                  child: Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.only(left: 20.w, top: 5.h, bottom: 5.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: settingProvider.settings.darkTheme == null
                              ? MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? Color(0xff1c1c1e)
                                  : Color(0xffc6c6c6)
                              : settingProvider.settings.darkTheme!
                                  ? Color(0xff1c1c1e)
                                  : Color(0xffc6c6c6),
                          width: 2.sp),
                    ),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Theme',
                                style: context.textStyles.mRegular(),
                              ),
                              Text(
                                settingProvider.settings.darkTheme == null
                                    ? "System"
                                    : settingProvider.settings.darkTheme!
                                        ? "Dark"
                                        : "Light",
                                style: context.textStyles
                                    .sRegular()
                                    .copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 35.sp,
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                      ],
                    ),
                    // child: SwithListTile(
                    //   type: 'Dark Theme',
                    // ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                // Container(
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(
                //       8.h,
                //     ),
                //     border: Border.all(
                //       color: const Color(0xffc6c6c6),
                //       width: 2,
                //     ),
                //     color: const Color(0xFFF6F6F6),
                //   ),
                //   height: 50.h,
                //   width: double.maxFinite,
                //   alignment: Alignment.center,
                //   padding: EdgeInsets.only(left: 15.w),
                //   child: Row(
                //     children: [
                //       const Icon(
                //         Icons.router_outlined,
                //         color: Colors.red,
                //       ),
                //       SizedBox(
                //         width: 10.w,
                //       ),
                //       Expanded(
                //         child: Text(
                //           'Live Activity',
                //           style: AppTextStyles().mRegular(),
                //         ),
                //       ),
                //       CupertinoSwitch(
                //         value: settingProvider.settings.liveActivity,
                //         onChanged: (value) {
                //           settingProvider.settings.liveActivity = value;
                //           settingProvider.setAllUnits(settingProvider.settings);
                //            HiveSettingsDB()
                //                     .updateSettings(settingProvider.settings);
                //           // settingProvider.settings.setLiveActivity(value);
                //         },
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(
                //   height: 15.h,
                // ),
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.only(left: 20.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: settingProvider.settings.darkTheme == null
                            ? MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Color(0xff1c1c1e)
                                : Color(0xffc6c6c6)
                            : settingProvider.settings.darkTheme!
                                ? Color(0xff1c1c1e)
                                : Color(0xffc6c6c6),
                        width: 2.sp),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () async {
                          final Uri _emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'carpediem.bk@outlook.com',
                            query: 'subject=Feedback on Speedometer GPS App',
                          );

                          if (await canLaunchUrl(_emailLaunchUri)) {
                            await launchUrl(_emailLaunchUri);
                          } else {
                            throw 'Could not launch email';
                          }
                        },
                        child: Container(
                          height: 50.h,
                          padding: EdgeInsets.only(top: 5.h),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.mail_outline,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Expanded(
                                child: Text(
                                  'Send Feedback',
                                  style: context.textStyles.mRegular(),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 35.sp,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final Uri _emailLaunchUri = Uri.parse(
                              "https://gist.github.com/thisjustin93/5dba4ba4df80ad4999da751cef10ad95");

                          if (await canLaunchUrl(_emailLaunchUri)) {
                            await launchUrl(_emailLaunchUri);
                          } else {
                            throw 'Could not launch email';
                          }
                        },
                        child: Container(
                          height: 50.h,
                          padding: EdgeInsets.only(top: 5.h),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.grey))),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.privacy_tip_rounded,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Expanded(
                                child: Text(
                                  'Privacy Policy',
                                  style: context.textStyles.mRegular(),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 35.sp,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          void shareApp() {
                            Share.share(
                                'Check out this amazing app! https://yourappurl.com');
                          }
                        },
                        child: Container(
                          height: 50.h,
                          padding: EdgeInsets.only(top: 5.h),
                          // decoration: const BoxDecoration(
                          //     border:
                          //         Border(bottom: BorderSide(color: Colors.grey))),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.file_upload_outlined,
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Expanded(
                                child: Text(
                                  'Share this app',
                                  style: context.textStyles.mRegular(),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.onPrimary,
                                size: 35.sp,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
