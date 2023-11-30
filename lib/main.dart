import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/models/purchases_configuration.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:speedometer/core/models/PedometerSessionModel.dart';
import 'package:speedometer/core/models/SettingsModel.dart';
import 'package:speedometer/core/models/UserModel.dart';
import 'package:speedometer/core/providers/app_start_session_provider.dart';
import 'package:speedometer/core/providers/pedometer_session_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speedometer/core/providers/subscription_provider.dart';
import 'package:speedometer/core/providers/unit_settings_provider.dart';
import 'package:speedometer/core/providers/user_provider.dart';
import 'package:speedometer/core/services/auth_services.dart';
import 'package:speedometer/core/services/hive_database_services.dart';
import 'package:speedometer/features/Auth/auth_screen.dart';
import 'package:speedometer/main_navigation_screen.dart';

final _configuration =
    PurchasesConfiguration("appl_sDdhLlXJTkAvLSEdUqSePzlkUjF");

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Purchases.configure(_configuration);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();

  Hive
    ..initFlutter(appDocumentDir.path)
    ..registerAdapter(PedometerSessionAdapter())
    ..registerAdapter(SettingsModelAdapter());
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  MobileAds.instance.initialize();
  RequestConfiguration configuration = RequestConfiguration(testDeviceIds: [
    'AD9AEB3A8102D4B5967050E524F217DE',
    "8273197a8c8172e4f599d2b54dc061467dfa87be"
  ]);
  MobileAds.instance.updateRequestConfiguration(configuration);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // StreamProvider<UserModel>.value(
        //   initialData: UserModel(userId: '0'),
        //   value: AuthService().user,
        // ),
        // ChangeNotifierProvider(
        //   create: (context) => UserProvider(),
        // ),
        ChangeNotifierProvider(
          create: (context) => PedoMeterSessionProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => SubscriptionProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => RecordingProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => UnitsProvider(),
        ),
      ],
      child: ScreenUtilInit(
          designSize: Size(360, 712),
          builder: (context, child) {
            var settings = Provider.of<UnitsProvider>(context).settings;
            return MaterialApp(
              localizationsDelegates: [
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
                // GlobalMaterialLocalizations.delegate,
                // GlobalWidgetsLocalizations.delegate,
                // GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                Locale('en', 'US'),
              ],
              debugShowCheckedModeBanner: false,
              themeMode: settings.darkTheme == null
                  ? MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? ThemeMode.dark
                      : ThemeMode.light
                  : settings.darkTheme!
                      ? ThemeMode.dark
                      : ThemeMode.light,
              darkTheme: ThemeData(
                  colorScheme: ColorScheme.fromSwatch(
                    cardColor: Colors.white,
                    backgroundColor: Colors.black,
                  ).copyWith(
                    primary: Color(0xff1c1c1e),
                    onPrimary: Color(0xffe5e5e5),
                  ),
                  useMaterial3: true,
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    backgroundColor: Colors.white,
                    unselectedIconTheme: IconThemeData(color: Colors.grey),
                  ),
                  visualDensity: VisualDensity.defaultDensityForPlatform(
                      TargetPlatform.iOS)),
              theme: ThemeData(
                  colorScheme: ColorScheme.fromSwatch(
                    cardColor: Colors.white,
                    backgroundColor: Colors.white,
                  ).copyWith(
                    primary: Color(0xFFF6F6F6),
                    onPrimary: Colors.black,
                  ),
                  useMaterial3: true,
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    backgroundColor: Colors.white,
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
