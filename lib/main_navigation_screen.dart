import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/pedometer_session.dart';
import 'package:speedometer/core/services/hive_database_services.dart';
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

  getallsession() async {
    List<PedometerSession> sessions =
        await HiveDatabaseServices().getAllSessions();
    Provider.of<PedoMeterSessionProvider>(context, listen: false)
        .updatePedometerSessionList(sessions);
  }

  @override
  void initState() {
    getallsession();

    super.initState();
  }

  static List<Widget> screens = [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[pageIndex],
      bottomNavigationBar: CupertinoTabBar(
        // showSelectedLabels: false,
        // showUnselectedLabels: false,
        // selectedIconTheme: IconThemeData(size: 35.sp, color: Colors.red),
        // unselectedIconTheme: IconThemeData(size: 35.sp),
        // iconSize: 35.sp,
        activeColor: Colors.red,
        currentIndex: pageIndex,
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            // label: 'Home',
            icon: Icon(Icons.home_outlined),
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
    );
  }
}
