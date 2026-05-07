import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _diamondController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _diamondRotationAnimation;
  String currentVersion = '';
  String latestVersion = '';
  bool? isExistP;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
    _checkInfo();
  }

  Future<void> _checkInfo() async {
    final info = await PackageInfo.fromPlatform();
    currentVersion = info.version;

    print(currentVersion + ' ===============');

    final doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('generalSettings')
        .get();

    final data = doc.data()!;
    latestVersion = data['latestVersion'] ?? currentVersion;
    isExistP = data['isExistP'];

    print(latestVersion + ' L===============');
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _diamondController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _diamondRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _diamondController, curve: Curves.linear),
    );
  }

  void _startSplashSequence() {
    _logoController.forward();
    Timer(Duration(milliseconds: 500), () {
      _diamondController.repeat();
    });

    Timer(Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }

  // Widget miseAjour() {
  //   return
  // }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('firstTime') ?? true;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && !isFirstTime) {
      // Fetch user lastActive from Firestore
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final docSnap = await userDoc.get();
      print('${isExistP} =============');
      final now = DateTime.now();
      if (docSnap.exists) {
        final data = docSnap.data();
        final lastActiveTimestamp = data?['lastActive'];
        DateTime? lastActive;

        if (lastActiveTimestamp is Timestamp) {
          lastActive = lastActiveTimestamp.toDate();
        } else if (lastActiveTimestamp is DateTime) {
          lastActive = lastActiveTimestamp;
        }
        bool isSameDay =
            lastActive != null &&
            lastActive.year == now.year &&
            lastActive.month == now.month &&
            lastActive.day == now.day;
        if (isSameDay) {
          // Just update lastActive
          await userDoc.update({'lastActive': now});
        } else {
          // Update lastActive and reset tokenCount
          await userDoc.update({'lastActive': now, 'tokenCount': 0});
        }
        if (!data?['isVerify']) {
          if (isExistP!) {
            Navigator.pushReplacementNamed(context, '/status');
          } else if (latestVersion != currentVersion) {
            Navigator.pushReplacementNamed(context, '/miseajour');
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
          return;
        }
      }
      if (isExistP!) {
        Navigator.pushReplacementNamed(context, '/status');
      } else if (latestVersion != currentVersion) {
        Navigator.pushReplacementNamed(context, '/miseajour');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (isExistP!) {
        Navigator.pushReplacementNamed(context, '/status');
      } else if (latestVersion != currentVersion) {
        Navigator.pushReplacementNamed(context, '/miseajour');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _diamondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C),
      body: GestureDetector(
        onTap: _navigateToNextScreen,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF4500), Color(0xFFFFD700)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF4500).withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'TT',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF0F0F0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 30),
              // App Name
              FadeTransition(
                opacity: _logoFadeAnimation,
                child: Text(
                  'TokenTrove',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                    letterSpacing: 2,
                  ),
                ),
              ),
              SizedBox(height: 50),
              // Rotating Diamond
              AnimatedBuilder(
                animation: _diamondController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _diamondRotationAnimation.value * 2 * 3.14159,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1E90FF), Color(0xFFFFD700)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF1E90FF).withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.diamond,
                        color: Color(0xFFF0F0F0),
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
