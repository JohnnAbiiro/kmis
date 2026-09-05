import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ksoftsms/controller/accountProvider.dart';
import 'package:ksoftsms/controller/dbmodels/employee_provider.dart';
import 'package:ksoftsms/controller/loginprovider.dart';
import 'package:ksoftsms/controller/payroll_provider.dart';
import 'package:ksoftsms/pushNotification.dart';
import 'package:provider/provider.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/routes.dart';
import 'controller/dbmodels/app_Provider.dart';
import 'controller/statsprovider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await NotificationService().initNotifications();
  if(!kIsWeb) {
    await PushNotificationService().initialize();
  }
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  final myProvider = Myprovider();
  await myProvider.loadThemeMode();

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: myProvider),
        ChangeNotifierProvider(create: (context) => StatsProvider()),
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        ChangeNotifierProvider(create: (context) => AccountProvider()),
        ChangeNotifierProvider(create: (context) => PayrollProvider()),
        ChangeNotifierProvider(create: (context) => EmployeeProvider()),
        ChangeNotifierProvider(create: (context) => AppProvider()),
      ],
      child: MyApp(),
    ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Myprovider>(
      builder: (context, provider, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'KologSoft MIS',
          themeMode: provider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFFFFDF8),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFFFFDF8),
              elevation: 0,
              centerTitle: false,
              iconTheme: IconThemeData(color: Colors.deepOrange),
              titleTextStyle: TextStyle(
                color: Colors.deepOrange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orangeAccent,
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E),
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
              centerTitle: false,
              iconTheme: IconThemeData(color: Colors.orangeAccent),
              titleTextStyle: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          routerConfig: router,
        );
      },
    );
  }
}
