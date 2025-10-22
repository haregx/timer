import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'screen/timer_screen.dart';

import 'package:timer/services/notification_service.dart';

/// Entry point of the Timer application.
/// Initializes and runs the main application widget. 
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.instance.init();
  debugPrint('NotificationService initialisiert');
  // iOS: explizite Berechtigungsabfrage
  await NotificationService.instance.plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.
    requestPermissions(alert: true, badge: true, sound: true);
  // On Android, permission is handled automatically. On iOS, request via plugin if needed.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

/// Main Application Widget - Timer App
/// Sets up the MaterialApp with theme and home screen. 
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Timer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const TimerScreen(),
    );
  }
}

