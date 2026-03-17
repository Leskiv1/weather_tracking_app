import 'package:flutter/material.dart';
import 'features/home/screens/home_screen.dart';

void main() {
  runApp(const WeatherTrackerApp());
}

class WeatherTrackerApp extends StatelessWidget {
  const WeatherTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto', // Або будь-який інший стандартний шрифт
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}