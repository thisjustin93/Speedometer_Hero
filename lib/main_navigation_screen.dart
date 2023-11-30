import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/models/SettingsModel.dart';
import 'package:speedometer/core/providers/app_start_session_provider.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/subscription_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/providers/user_provider.dart';
import 'package:speedometer/core/services/ad_mob_service.dart';
import 'package:speedometer/core/services/hive_database_services.dart';
import 'package:speedometer/core/services/settigns_db_services.dart';
import 'package:speedometer/features/history/screens/history_screen.dart';
import 'package:speedometer/features/home/screens/home_screen.dart';
import 'package:speedometer/features/settings/screens/settings_page.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int pageIndex = 0;
  bool recordingStarted = false;
  BannerAd? _banner;
  void _createBannerAd(bool isLandscape, Size size) {
    _banner = BannerAd(
        size: AdSize(width: size.width.toInt(), height: 60),
        // size: AdSize.fluid,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerAdListener,
        request: const AdRequest())
      ..load();
    print(
        "_banner!.responseInfo${_banner!.responseInfo}${_banner!.responseInfo.runtimeType}");
    print(_banner!.responseInfo != null);
    setState(() {});
  }

  getallsession() async {
    List<PedometerSession> sessions =
        await HiveDatabaseServices().getAllSessions();
    Provider.of<PedoMeterSessionProvider>(context, listen: false)
        .updatePedometerSessionList(sessions);
  }

  getSettings(bool isDarkTheme) async {
    SettingsModel settings = await HiveSettingsDB().getSettings(isDarkTheme);

    Provider.of<UnitsProvider>(context, listen: false).setAllUnits(settings);
  }

  checkSubscription() async {
    // SubscriptionStatus status =
    //     Provider.of<UserProvider>(context, listen: false)
    //             .user!
    //             .isUserSubscribed!
    //         ? SubscriptionStatus.subscribed
    //         : SubscriptionStatus.notSubscribed;
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    print(customerInfo.toJson().toString());
    SubscriptionStatus status =
        customerInfo.allPurchasedProductIdentifiers.isNotEmpty
            ? SubscriptionStatus.subscribed
            : SubscriptionStatus.notSubscribed;
    Future.delayed(
      Duration(milliseconds: 1),
      () {
        Provider.of<SubscriptionProvider>(context, listen: false)
            .setSubscriptionStatus(status);
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bool isDarkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    getallsession();
    checkSubscription();
    getSettings(isDarkTheme);
    _createBannerAd(MediaQuery.of(context).orientation == Orientation.landscape,
        MediaQuery.sizeOf(context));
  }

  static List<Widget> screens = [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen()
  ];
  Future<void> setOrientation(int pageIndex) async {
    if (pageIndex == 0) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
    }
  }

  @override
  Widget build(BuildContext context) {
    setOrientation(pageIndex);

    recordingStarted =
        Provider.of<RecordingProvider>(context, listen: true).recordingStarted;
    bool isUserSubscribed =
        Provider.of<SubscriptionProvider>(context, listen: false).status ==
            SubscriptionStatus.subscribed;
    return Scaffold(
      body: screens[pageIndex],
      bottomNavigationBar: MediaQuery.of(context).orientation ==
                  Orientation.landscape &&
              !isUserSubscribed
          ? Container(
              height: 45.h,
              child: AdWidget(ad: _banner!),
            )
          : Container(
              height: _banner == null || isUserSubscribed ? 50.h : 115.h,
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isUserSubscribed)
                    Container(
                      height: _banner == null ? 0 : 65.h,
                      width: MediaQuery.of(context).size.width,
                      child: _banner == null ? null : AdWidget(ad: _banner!),
                    ),
                  Padding(
                    padding: EdgeInsets.only(left: 35.w, right: 35.w),
                    child: CupertinoTabBar(
                      // backgroundColor: Color(0xFFF6F6F6),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      activeColor: Colors.red,
                      border: Border.all(color: Colors.transparent),
                      // activeColor: recordingStarted ? Colors.grey : Colors.red,
                      currentIndex: pageIndex,
                      onTap: (value) {
                        setState(() {
                          pageIndex = value;
                          if (value != 0) {
                            Provider.of<RecordingProvider>(context,
                                    listen: false)
                                .stopRecording();
                          }
                        });
                      },
                      iconSize: 35.sp,
                      items: [
                        BottomNavigationBarItem(
                            // label: 'Home',
                            icon: Icon(Icons.home)
                            // icon: !recordingStarted
                            //     ? Icon(Icons.home)
                            //     : Icon(Icons.assistant_navigation),
                            ),
                        BottomNavigationBarItem(
                          // label: "Data",
                          icon: Icon(Icons.article),
                        ),
                        BottomNavigationBarItem(
                          // label: 'Settings',
                          icon: Icon(Icons.settings),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
