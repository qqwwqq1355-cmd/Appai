import 'package:flutter/material.dart';
import 'package:marketlens/screens/camera_screen.dart';
import 'package:marketlens/screens/home_screen.dart';
import 'package:marketlens/screens/login_screen.dart';
import 'package:marketlens/screens/results_screen.dart';
import 'package:marketlens/screens/splash_screen.dart';
import 'package:marketlens/screens/profile_screen.dart';
import 'package:marketlens/screens/onboarding_screen.dart';
import 'package:marketlens/screens/register_screen.dart';
import 'package:marketlens/screens/product_detail_screen.dart';
import 'package:marketlens/screens/comparison_screen.dart';
import 'package:marketlens/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarketLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follows system theme
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/camera': (context) => const CameraScreen(),
        '/results': (context) => const ResultsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/comparison': (context) => const ComparisonScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == '/product-detail') {
          final product = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}
