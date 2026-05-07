import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:flutter/material.dart' hide TextDirection;
import 'package:intl/intl.dart' hide TextDirection;
import '../widgets/main_scaffold.dart';

String version = "";

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String nickname = '';
  int tokenCount = 0;
  int todayCodeCount = 0;
  int totalTokenCount = 0;
  int userRank = 0;
  int notificationsUnseen = 0;
  bool loading = true;
  bool loadingNotifications = true;
  bool loadingRank = true;
  late Timer _timer;
  Duration timeToReset = Duration();
  String generatedCode = '';
  bool codeGenerated = false;
  String _lang = 'en';

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        timeToReset = _getTimeToWeekReset();
      });
    });
  }

  Duration _getTimeToWeekReset() {
    final now = DateTime.now().toUtc();
    final nextSunday = now.add(Duration(days: (7 - now.weekday) % 7));
    final reset = DateTime.utc(
      nextSunday.year,
      nextSunday.month,
      nextSunday.day,
    );
    return reset.difference(now);
  }

  Future<void> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    version = packageInfo.version; // e.g. "1.0.3"
  }

  Future<void> _fetchAllData() async {
    if (user == null) return;
    final uid = user!.uid;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
    final weekId = _getCurrentWeekId();
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final codeUsageDoc = await FirebaseFirestore.instance
          .collection('codeUsage')
          .doc('${uid}_$today')
          .get();
      final leaderboardDoc = await FirebaseFirestore.instance
          .collection('leaderboard')
          .doc(weekId)
          .get();
      setState(() {
        nickname = userDoc.data()?['name'] ?? '';
        tokenCount = userDoc.data()?['tokenCount'] ?? 0;
        totalTokenCount = userDoc.data()?['totalTokenCount'] ?? 0;
        todayCodeCount = codeUsageDoc.data()?['count'] ?? 0;
        userRank = leaderboardDoc.data()?['ranks']?[uid] ?? 0;
        _lang = userDoc.data()?['settings']?['language'] ?? 'en';
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
    getAppVersion();
  }

  String _getCurrentWeekId() {
    final now = DateTime.now().toUtc();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday % 7));
    return DateFormat('yyyy-MM-dd').format(firstDayOfWeek);
  }

  String _generateFormattedCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();

    String getBlock() =>
        List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join();

    return '${getBlock()} ${getBlock()} ${getBlock()} ${getBlock()}';
  }

  Future<void> _generateCode() async {
    print(
      'today\'s token = $tokenCount\ntoday code count = $todayCodeCount ============',
    );
    if (todayCodeCount >= 30) return;
    print('=============');
    if (tokenCount < 15) {
      print('15=============');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${_tr('youmust15')}')));
      return;
    }
    if (tokenCount < 30 && todayCodeCount >= 5 && todayCodeCount < 10) {
      print('30=============');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${_tr('youmust30')}')));
      return;
    }
    if (tokenCount < 45 && todayCodeCount >= 10 && todayCodeCount < 15) {
      print('45=============');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${_tr('youmust45')}')));
      return;
    }
    if (tokenCount < 60 && todayCodeCount >= 15 && todayCodeCount < 20) {
      print('60=============');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${_tr('youmust60')}')));
      return;
    }
    if (tokenCount < 75 && todayCodeCount >= 20 && todayCodeCount < 25) {
      print('75=============');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${_tr('youmust75')}')));
      return;
    }
    if (tokenCount < 90 && todayCodeCount >= 25 && todayCodeCount < 30) {
      print('90=============');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${_tr('youmust90')}')));
      return;
    }

    setState(() {
      todayCodeCount++;
      generatedCode = _generateFormattedCode();
      codeGenerated = true;
    });
    final uid = user!.uid;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
    await FirebaseFirestore.instance
        .collection('codeUsage')
        .doc('${uid}_$today')
        .set({'count': todayCodeCount}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Color(0xFFFF4500);
    final secondary = Color(0xFF1E90FF);
    final accent = Color(0xFFFFD700);
    final background = Color(0xFF1C1C1C);
    final cardBg = Color(0xFF232323);
    final textColor = Color(0xFFF0F0F0);
    return loading
        ? Center(child: CircularProgressIndicator(color: secondary))
        : MainScaffold(
            currentIndex: 0,
            onTab: (i) {
              if (i == 0) return;
              switch (i) {
                case 1:
                  Navigator.pushReplacementNamed(context, '/methods');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/leaderbord');
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, '/league');
                  break;
                case 4:
                  Navigator.pushReplacementNamed(context, '/profile');
                  break;
              }
            },
            child: Directionality(
              textDirection: _lang == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: background,
                appBar: AppBar(
                  backgroundColor: background,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: secondary,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  title: loading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[800]!,
                          highlightColor: Colors.grey[600]!,
                          child: Container(
                            width: 120,
                            height: 18,
                            color: Colors.grey[800],
                          ),
                        )
                      : Text(
                          _welcomeText(nickname),
                          style: TextStyle(color: textColor, fontSize: 20),
                        ),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsPanel(primary, secondary, accent, textColor),
                        SizedBox(height: 44),
                        _buildCodeGeneratorSection(
                          cardBg,
                          background,
                          accent,
                          secondary,
                          textColor,
                        ),
                        SizedBox(height: 24),
                        _buildEarnTokensButton(primary, accent, textColor),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildStatsPanel(
    Color primary,
    Color secondary,
    Color accent,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.7), secondary.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: accent, width: 2),
      ),
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.card_giftcard,
            tokenCount,
            _tr("todaysTokens"),
            accent,
          ),
          _buildStatItem(
            Icons.all_inbox,
            totalTokenCount,
            _tr('totalTokens'),
            primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    int value,
    String label,
    Color iconColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        SizedBox(height: 6),
        Animate(
          effects: [FadeEffect(), ScaleEffect()],
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  Widget _buildCodeGeneratorSection(
    Color cardBg,
    Color background,
    Color accent,
    Color secondary,
    Color textColor,
  ) {
    final codesLeft = 30 - todayCodeCount;
    final canGenerate = codesLeft > 0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg.withOpacity(0.98),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.15),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: accent.withOpacity(0.5), width: 1.5),
          ),
          padding: EdgeInsets.fromLTRB(18, 38, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 18),
              Text(
                _tr('freeFireCodeGenerator'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 18),
              TextField(
                readOnly: true,
                textAlign: TextAlign.center,
                controller: TextEditingController(
                  text: codeGenerated ? generatedCode : '',
                ),
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 2.5,
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accent, width: 1.2),
                  ),
                  hintText: _tr('yourCodeWillAppearHere'),
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canGenerate ? secondary : null,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  elevation: 4,
                ),
                onPressed: canGenerate ? _generateCode : null,
                icon: Icon(Icons.vpn_key),
                label: Text(
                  canGenerate ? _tr('generateCode') : _tr('comeBackTomorrow'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Text(
                _codesLeftText(codesLeft),
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ],
          ),
        ),
        Positioned(
          top: -32,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: background,
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: EdgeInsets.all(10),
              child: Icon(Icons.diamond, color: secondary, size: 38),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEarnTokensButton(Color primary, Color accent, Color textColor) {
    return Center(
      child: _PulsingButton(
        onTap: () {
          Navigator.pushReplacementNamed(context, '/methods');
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.5),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on, color: accent, size: 28),
              SizedBox(width: 10),
              Text(
                '💰 ' + _tr('earnTokens'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _tr(String key) {
    final isAr = _lang == 'ar';
    switch (key) {
      case 'todaysTokens':
        return isAr ? 'رموز اليوم' : "Today's Tokens";
      case 'totalTokens':
        return isAr ? 'إجمالي الرموز' : 'Total Tokens';
      case 'freeFireCodeGenerator':
        return isAr ? 'مولّد أكواد فري فاير' : 'Free Fire Code Generator';
      case 'yourCodeWillAppearHere':
        return isAr ? 'سيظهر رمزك هنا' : 'Your code will appear here';
      case 'generateCode':
        return isAr ? 'توليد رمز' : 'Generate Code';
      case 'comeBackTomorrow':
        return isAr ? 'عد غداً!' : 'Come back tomorrow!';
      case 'earnTokens':
        return isAr ? 'اكسب الرموز' : 'Earn Tokens';
      case 'youmust15':
        return isAr
            ? 'يجب أن يكون لديك 15 رموز على الأقل اليوم، شاهد الإعلانات للحصول على المزيد من الرموز'
            : 'You must have at least 15 today\'s tokens , watch ads for more token';
      case 'youmust30':
        return isAr
            ? 'يجب أن يكون لديك 30 رموز على الأقل اليوم، شاهد الإعلانات للحصول على المزيد من الرموز'
            : 'You must have at least 30 today\'s tokens , watch ads for more token';
      case 'youmust45':
        return isAr
            ? 'يجب أن يكون لديك 45 رموز على الأقل اليوم، شاهد الإعلانات للحصول على المزيد من الرموز'
            : 'You must have at least 45 today\'s tokens , watch ads for more token';
      case 'youmust60':
        return isAr
            ? 'يجب أن يكون لديك 60 رموز على الأقل اليوم، شاهد الإعلانات للحصول على المزيد من الرموز'
            : 'You must have at least 60 today\'s tokens , watch ads for more token';
      case 'youmust75':
        return isAr
            ? 'يجب أن يكون لديك 75 رموز على الأقل اليوم، شاهد الإعلانات للحصول على المزيد من الرموز'
            : 'You must have at least 75 today\'s tokens , watch ads for more token';
      case 'youmust90':
        return isAr
            ? 'يجب أن يكون لديك 90 رموز على الأقل اليوم، شاهد الإعلانات للحصول على المزيد من الرموز'
            : 'You must have at least 90 today\'s tokens , watch ads for more token';
      default:
        return key;
    }
  }

  String _welcomeText(String name) {
    return _lang == 'ar' ? 'مرحباً، ' + name : 'Welcome, ' + name;
  }

  String _codesLeftText(int left) {
    return _lang == 'ar'
        ? 'لديك ' + left.toString() + '/30 رمزاً متبقياً اليوم'
        : 'You have ' + left.toString() + '/30 codes left today';
  }
}

class _PulsingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PulsingButton({required this.child, this.onTap, Key? key})
    : super(key: key);

  @override
  State<_PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<_PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
