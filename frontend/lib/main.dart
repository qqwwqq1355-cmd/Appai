import 'package:flutter/material.dart';
import 'package:shoplensx/screens/camera_screen.dart';
import 'package:shoplensx/screens/home_screen.dart';
import 'package:shoplensx/screens/login_screen.dart';
import 'package:shoplensx/screens/results_screen.dart';
import 'package:shoplensx/screens/splash_screen.dart';
import 'package:shoplensx/screens/profile_screen.dart';
import 'package:shoplensx/screens/onboarding_screen.dart';
import 'package:shoplensx/screens/register_screen.dart';
import 'package:shoplensx/screens/product_detail_screen.dart';
import 'package:shoplensx/screens/comparison_screen.dart';
import 'package:shoplensx/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopLensX',
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
