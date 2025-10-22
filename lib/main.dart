import 'package:flutter/material.dart';
import 'screen/timer_screen.dart';

/// Entry point of the Timer application.
/// Initializes and runs the main application widget. 
void main() {
  runApp(const MyApp());
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

