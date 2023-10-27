import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/models/SettingsModel.dart';
import 'package:speedometer/core/providers/app_start_session_provider.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:speedometer/core/providers/subscription_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
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
  bool appStartSession = true;
  BannerAd? _banner;
  void _createBannerAd(bool isLandscape) {
    _banner = BannerAd(
        size: isLandscape ? AdSize(width: 500, height: 60) : AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerAdListener,
        request: const AdRequest())
      ..load();
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
    SubscriptionStatus status = SubscriptionStatus.subscribed;
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
    _createBannerAd(
        MediaQuery.of(context).orientation == Orientation.landscape);
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
    print(MediaQuery.of(context).platformBrightness);

    setOrientation(pageIndex);

    appStartSession =
        Provider.of<AppStartProvider>(context, listen: true).appStartSession;

    return Scaffold(
      body: screens[pageIndex],
      bottomNavigationBar: MediaQuery.of(context).orientation ==
              Orientation.landscape
          ? Container(
              height: 45.h,
              child: AdWidget(ad: _banner!),
            )
          : Container(
              height: 120.h,
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 45.h,
                    width: MediaQuery.of(context).size.width,
                    child: AdWidget(ad: _banner!),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35.w,verticle:10.h),
                    child: CupertinoTabBar(
                      // backgroundColor: Color(0xFFF6F6F6),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      activeColor: appStartSession ? Colors.grey : Colors.red,
                      currentIndex: pageIndex,
                      onTap: (value) {
                        Provider.of<AppStartProvider>(context, listen: false)
                            .changeState();
                        setState(() {
                          pageIndex = value;
                        });
                      },
                      iconSize: 35.sp,
                      items: [
                        BottomNavigationBarItem(
                          // label: 'Home',
                          icon: pageIndex != 0 || appStartSession
                              ? Icon(Icons.home_outlined)
                              : Icon(Icons.assistant_navigation),
                        ),
                        BottomNavigationBarItem(
                          // label: "Data",
                          icon: Icon(Icons.article_outlined),
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
