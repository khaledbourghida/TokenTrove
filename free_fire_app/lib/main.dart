import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:free_fire_app/screens/earnMethod_screen.dart';
import 'package:free_fire_app/screens/leaderbord.dart';
import 'package:free_fire_app/screens/leage_screen.dart';
import 'package:free_fire_app/screens/miseAjour_screen.dart';
import 'package:free_fire_app/screens/profile_screen.dart';
import 'package:free_fire_app/screens/status_screen.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'services/ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Start global interstitial scheduler (Unity Ads every 3 minutes)
  UnityInterstitialScheduler.instance.start();

  runApp(FireCrateApp());
}

class FireCrateApp extends StatelessWidget {
  const FireCrateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TokenTrove',
      theme: ThemeData(
        primaryColor: Color(0xFFFF4500),
        scaffoldBackgroundColor: Color(0xFF1C1C1C),
        fontFamily: 'SpaceMono',
      ),
      home: SplashScreen(),
      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/methods': (context) => EarnmethodScreen(),
        '/leaderbord': (context) => LeaderbordScreen(),
        '/league': (context) => LeageScreen(),
        '/profile': (context) => ProfileScreen(),
        '/status': (context) => AppStatusPage(),
        '/miseajour': (context) => UpdatePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
