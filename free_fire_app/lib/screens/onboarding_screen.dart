import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Earn Tokens Easily",
      description: "Watch ads and earn daily tokens with no hassle.",
      icon: Icons.monetization_on,
      color: Color(0xFFFFD700),
    ),
    OnboardingData(
      title: "Compete Weekly",
      description: "Join individual or squad leagues and win real FF Diamonds.",
      icon: Icons.emoji_events,
      color: Color(0xFF1E90FF),
    ),
    OnboardingData(
      title: "Climb the Leaderboard",
      description: "Be the top earner and claim your weekly prize.",
      icon: Icons.leaderboard,
      color: Color(0xFFFF4500),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _iconController.reset();
    _iconController.forward();
  }

  Future<void> _handleGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstTime', false);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon
          AnimatedBuilder(
            animation: _iconAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _iconAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        data.color.withOpacity(0.3),
                        data.color.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: data.color.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(data.icon, size: 60, color: data.color),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          // Title
          Text(
            data.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700),
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // Description
          Text(
            data.description,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFF0F0F0),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => _buildDotIndicator(index),
            ),
          ),
          SizedBox(height: 40),
          // Get Started Button (only on last page)
          if (_currentPage == _pages.length - 1)
            _buildGetStartedButton()
          else
            SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: _currentPage == index ? 30 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? Color(0xFFFF4500) : Color(0xFF444444),
        borderRadius: BorderRadius.circular(5),
        boxShadow: _currentPage == index
            ? [
                BoxShadow(
                  color: Color(0xFFFF4500).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _handleGetStarted,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF4500),
          foregroundColor: Color(0xFFF0F0F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 10,
          shadowColor: Color(0xFFFF4500).withOpacity(0.5),
        ),
        child: Text(
          'Get Started',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
