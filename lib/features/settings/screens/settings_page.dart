import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/providers/subscription_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/services/settigns_db_services.dart';
import 'package:speedometer/core/styling/text_styles.dart';
import 'package:speedometer/core/utils/extensions/context.dart';
import 'package:speedometer/features/settings/widgets/switch_listtile_widget.dart';

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
  ];
  List<Unit> elevationUnits = [
    Unit(key: 'ft', value: 'Feet'),
    Unit(key: 'm', value: 'Meters')
  ];
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
                          color: settingProvider.settings.darkTheme
                              ? Color(0xff1c1c1e)
                              : Color(0xffc6c6c6),
                          width: 2.sp),
                    ),
                    child: Column(
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
                        Text(
                          'Buy the premium version of Speedometer GPSto unlock the full experienceincl. no ads, unlimited activity history & ability to exp data',
                          textAlign: TextAlign.center,
                          style: context.textStyles.mRegular(),
                        ),
                        ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                fixedSize: Size(270.w, 40.h)),
                            child: const Text("Remove Ads"))
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
                        color: settingProvider.settings.darkTheme
                            ? Color(0xff1c1c1e)
                            : Color(0xffc6c6c6),
                        width: 2.sp),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 50.h,
                        padding: EdgeInsets.only(top: 5.h),
                        decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Speed Unit',
                                  style: context.textStyles.mRegular(),
                                ),
                                Text(
                                  settingProvider.settings.speedUnit == 'mph'
                                      ? "Miles Per Hour"
                                      : settingProvider.settings.speedUnit ==
                                              'kmph'
                                          ? "Kilometers Per Hour"
                                          : "Meters Per Second",
                                  style: context.textStyles.sRegular(),
                                ),
                              ],
                            ),
                            DropdownButton(
                              value: settingProvider.settings.speedUnit,
                              items: speedUnits
                                  .map(
                                    (unit) => DropdownMenuItem(
                                      value: unit.key,
                                      child: Text(
                                        unit.key,
                                        style: context.textStyles
                                            .sThick()
                                            .copyWith(color: Colors.red),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                // settingProvider.settings.setSpeedUnit(value!);
                                settingProvider.settings.speedUnit = value!;
                                settingProvider
                                    .setAllUnits(settingProvider.settings);
                                HiveSettingsDB()
                                    .updateSettings(settingProvider.settings);
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 50.h,
                        padding: EdgeInsets.only(top: 5.h),
                        decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
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
                            DropdownButton(
                              value: settingProvider.settings.elevationUnit,
                              items: elevationUnits
                                  .map(
                                    (unit) => DropdownMenuItem(
                                      value: unit.key,
                                      child: Text(
                                        unit.key,
                                        style: context.textStyles
                                            .sThick()
                                            .copyWith(color: Colors.red),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                settingProvider.settings.elevationUnit = value!;
                                settingProvider
                                    .setAllUnits(settingProvider.settings);
                                HiveSettingsDB()
                                    .updateSettings(settingProvider.settings);
                                // settingProvider.settings
                                //     .setElevationUnit(value!);
                              },
                            ),
                          ],
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
                                settingProvider.settings.maximumGaugeSpeed += 1;
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
                            InkWell(
                              onTap: () {
                                settingProvider.settings.maximumGaugeSpeed -= 1;
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.only(left: 20.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: settingProvider.settings.darkTheme
                              ? Color(0xff1c1c1e)
                              : Color(0xffc6c6c6),
                          width: 2.sp),
                    ),
                    child: SwithListTile(
                      type: 'Dark Theme',
                    )),
                SizedBox(
                  height: 15.h,
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
                        color: settingProvider.settings.darkTheme
                            ? Color(0xff1c1c1e)
                            : Color(0xffc6c6c6),
                        width: 2.sp),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 50.h,
                        padding: EdgeInsets.only(top: 5.h),
                        decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey))),
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
                            const Icon(Icons.chevron_right)
                          ],
                        ),
                      ),
                      Container(
                        height: 50.h,
                        padding: EdgeInsets.only(top: 5.h),
                        decoration: const BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey))),
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
                            const Icon(Icons.chevron_right)
                          ],
                        ),
                      ),
                      Container(
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
                            ),
                          ],
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
