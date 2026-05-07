import 'package:flutter/material.dart';
import 'package:free_fire_app/screens/exchage_screen.dart';
import 'package:free_fire_app/widgets/main_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class TokensScreen extends StatefulWidget {
  const TokensScreen({Key? key}) : super(key: key);

  @override
  State<TokensScreen> createState() => _TokensScreenState();
}

class _TokensScreenState extends State<TokensScreen> {
  String? _error;
  final user = FirebaseAuth.instance.currentUser;
  int _tokenCount = 0;
  int _totalTokenCount = 0;
  Timer? _countdownTimer;
  int _timer = 0;
  bool _adButtonEnabled = true;
  bool _loading = true;
  bool isExistP = false;
  bool _isLoadedReward = false;
  String _lang = 'en';

  @override
  void initState() {
    UnityAds.init(
      gameId: "5926795",
      onComplete: () {
        print('Unity Ads Initialized ==============');
        load_reward();
      },
      onFailed: (error, message) => print(
        '============= Unity Ads Initialization Failed: $error $message',
      ),
    );
    super.initState();
    _fetchTokenCount();
  }

  void load_reward() {
    UnityAds.load(
      placementId: 'Rewarded_Android',
      onComplete: (placementId) {
        print('Load Complete $placementId');
        setState(() {
          _isLoadedReward = true;
        });
      },
      onFailed: (placementId, error, message) =>
          print('Load Failed $placementId: $error $message'),
    );
  }

  void show_reward() {
    if (_isLoadedReward) {
      UnityAds.showVideoAd(
        placementId: 'Rewarded_Android',
        onStart: (placementId) => print('Video Ad $placementId started'),
        onClick: (placementId) => print('Video Ad $placementId click'),
        onSkipped: (placementId) => print('Video Ad $placementId skipped'),
        onComplete: (placementId) {
          print('Video Ad $placementId completed');
          setState(() {
            _isLoadedReward = false;
            _loading = true;
          });
          load_reward();
          setState(() async {
            // TODO give reward to user
            final cooldownEnd = DateTime.now().add(Duration(seconds: 60));
            _tokenCount++;
            _totalTokenCount++;

            final DocumentReference docRef = FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid);

            final DocumentSnapshot doc = await docRef.get();

            docRef.set({
              'cooldownUntil': Timestamp.fromDate(cooldownEnd),
              'tokenCount': _tokenCount,
              'totalTokenCount': _totalTokenCount,
            }, SetOptions(merge: true));

            final data = doc.data() as Map<String, dynamic>;
            if (data.containsKey('comp')) {
              docRef.set({'comp': data['comp'] + 1}, SetOptions(merge: true));
            }
            _fetchTokenCount();
          });
        },
        onFailed: (placementId, error, message) =>
            print('Video Ad $placementId failed: $error $message'),
      );
    } else {
      print('Wait the reward loaded');
    }
  }

  //=============================

  void _fetchTokenCount() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (user == null) throw Exception('User not logged in');
      final uid = user!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = doc.data();

      final int tokens = data?['tokenCount'] ?? 0;
      final int totalTokens = data?['totalTokenCount'] ?? 0;
      final Timestamp? cooldownTs = data?['cooldownUntil'];
      final String lang = data?['settings']?['language'] ?? 'en';
      print(lang + '===================');
      int remaining = 0;

      if (cooldownTs != null) {
        final cooldownEnd = cooldownTs.toDate();
        final now = DateTime.now();
        if (cooldownEnd.isAfter(now)) {
          remaining = cooldownEnd.difference(now).inSeconds;
          _startTimerFromRemaining(remaining);
        }
      }

      final doc2 = await FirebaseFirestore.instance
          .collection('settings')
          .doc('generalSettings')
          .get();
      final data2 = doc2.data();
      final bool problem = data2?['isExistAdP'] ?? false;

      setState(() {
        _tokenCount = tokens;
        _totalTokenCount = totalTokens;
        _timer = remaining;
        _adButtonEnabled = remaining == 0;
        _loading = false;
        isExistP = problem;
        _lang = lang;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _startTimerFromRemaining(int seconds) {
    _countdownTimer?.cancel();
    _timer = seconds;
    _adButtonEnabled = false;

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_timer <= 1) {
        timer.cancel();
        setState(() {
          _timer = 0;
          _adButtonEnabled = true;
        });
      } else {
        setState(() {
          _timer--;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Widget _buildWarningWindow() {
    final Color borderColor = Colors.orange; // or your primary color
    final Color background = Color(0xFF1C1C1C); // match your app bg
    final Color textColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: background,
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _tr('warningmessage'),
                style: TextStyle(color: textColor, fontSize: 12),
                textAlign: TextAlign.center, // optional
                softWrap: true,
              ),
            ),
          ),
          // Title "Rules" centered above the border
          Positioned(
            top: -16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: background,
                child: Text(
                  _tr('warning'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: borderColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Colors.orange;
    final Color textColor = Colors.white;
    final secondary = Color(0xFF1E90FF);
    final accent = Color(0xFFFFD700);
    final background = Color(0xFF1C1C1C);
    return _loading
        ? Center(child: CircularProgressIndicator(color: secondary))
        : Directionality(
            textDirection: _lang == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: background,
                iconTheme: IconThemeData(color: textColor),
              ),
              backgroundColor: background,
              body: isExistP
                  ? AdUnavailableWidget()
                  : ListView(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Countdown Timer Circle
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: accent, width: 6),
                                  color: background,
                                ),
                                child: Center(
                                  child: Text(
                                    _adButtonEnabled ? _tr('ready') : '$_timer',
                                    style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: accent,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 32),
                              // Watch Ad Button
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _adButtonEnabled
                                      ? secondary
                                      : Colors.grey[700],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 6,
                                ),
                                onPressed: () {
                                  _adButtonEnabled ? show_reward() : () {};
                                },
                                icon: Icon(Icons.ondemand_video),
                                label: Text(
                                  _tr('watchAndEarnToken'),
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              SizedBox(height: 18),
                              // Display Token Count Button
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: accent,
                                  side: BorderSide(color: accent, width: 2),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {},
                                icon: Icon(Icons.token),
                                label: Text(
                                  _tokensLabel(),
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              if (_error != null) ...[
                                SizedBox(height: 32),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              SizedBox(height: 40),
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ExchangeScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: secondary,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Text(
                                      _tr("exchangeTokenWithDiamond"),
                                    ),
                                  ),
                                ),
                              ),
                              _buildWarningWindow(),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          );
  }

  Widget AdUnavailableWidget() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.warning_amber_rounded, size: 40, color: Colors.orange),
          SizedBox(height: 12),
          Text(
            _tr("adsNotAvailable"),
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _tr("adsSetup"),
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _tr(String key) {
    final isAr = _lang == 'ar';
    switch (key) {
      case 'ready':
        return isAr ? 'جاهز' : 'Ready';
      case 'watchAndEarnToken':
        return isAr ? 'شاهد واربح رمزاً' : 'Watch & Earn Token';
      case 'tokens':
        return isAr ? 'الرموز' : 'Tokens';
      case 'exchangeTokenWithDiamond':
        return isAr ? 'استبدل الرموز بالألماس' : 'Exchange token with diamond';
      case 'adsNotAvailable':
        return isAr ? 'الإعلانات غير متاحة' : 'Ads not available';
      case 'adsSetup':
        return isAr
            ? 'نقوم حالياً بإعداد نظام الإعلانات.\nيرجى المحاولة لاحقاً.'
            : 'We’re currently setting up the ad system.\nPlease try again later.';
      case 'warningmessage':
        return isAr
            ? 'يمكن أن يحتوي الإعلان على ما يخالف الدين فإذا وجدت ذلك أخرج من التطبيق فقط و أعد الدخول'
            : 'The ad may contain content that is offensive to religion. If you find it, just exit the application and log in again.';
      case 'warning':
        return isAr ? 'تحذير' : 'Warning';
      default:
        return key;
    }
  }

  String _tokensLabel() {
    return _lang == 'ar' ? 'الرموز: $_tokenCount' : 'Tokens: $_tokenCount';
  }
}
