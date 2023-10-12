import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/providers/pedometer_session.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speedometer/core/services/hive_database_services.dart';
import 'package:speedometer/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive.initFlutter();
  // final sessionService = HiveDatabaseServices();
  // await sessionService.init();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();

  Hive
    ..initFlutter(appDocumentDir.path)
    ..registerAdapter(PedometerSessionAdapter());
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PedoMeterSessionProvider(),
        )
      ],
      child: ScreenUtilInit(
          designSize: Size(360, 712),
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  // primarySwatch: Colors.deepPurple,
                  useMaterial3: true,
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    backgroundColor: Color(0xFFF5F6F7),
                    unselectedIconTheme: IconThemeData(color: Colors.grey),
                  ),
                  visualDensity: VisualDensity.defaultDensityForPlatform(
                      TargetPlatform.iOS)),
              home: MainNavigationScreen(),
            );
          }),
    );
  }
}
