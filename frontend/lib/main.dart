import 'package:flutter/material.dart';
import 'package:marketlens/screens/camera_screen.dart';
import 'package:marketlens/screens/home_screen.dart';
import 'package:marketlens/screens/login_screen.dart';
import 'package:marketlens/screens/results_screen.dart';
import 'package:marketlens/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarketLens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/camera': (context) => const CameraScreen(),
        '/results': (context) => const ResultsScreen(),
      },
    );
  }
}
