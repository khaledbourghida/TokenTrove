// This code renders a leaderboard UI similar to your screenshot using your app theme
// Customize Firestore fields or icons as needed

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:free_fire_app/widgets/main_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class LeaderbordScreen extends StatefulWidget {
  const LeaderbordScreen({Key? key}) : super(key: key);

  @override
  State<LeaderbordScreen> createState() => _LeaderbordScreenState();
}

class _LeaderbordScreenState extends State<LeaderbordScreen> {
  bool _loading = true;
  bool isExist = false;
  List<DocumentSnapshot> _users = [];
  int _selectedIndex = -1;
  String? compTitle;
  Map<String, dynamic>? compPrizes;
  int userScore = 0;
  Map<String, bool> roles = {'isUser': true, 'isPrize': false, 'isRole': false};
  String _lang = 'en';

  final background = Color(0xFF1C1C1C);
  final accent = Color(0xFFFFD700);
  final secondary = Color(0xFF1E90FF);
  final primary = Color(0xFFFF4500);
  final textColor = Color(0xFFF0F0F0);

  Future<void> checkActiveCompetition(String userId) async {
    try {
      final compSnap = await FirebaseFirestore.instance
          .collection('competitions')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (compSnap.docs.isNotEmpty) {
        setState(() {
          isExist = true;
        });

        final compData = compSnap.docs.first.data();
        final compId = compSnap.docs.first.id;

        setState(() {
          compTitle = compData['title'];
          compPrizes = Map<String, dynamic>.from(compData['prizes']);
        });

        // Fetch user document
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        final data = userDoc.data();
        setState(() {
          userScore = data?["comp"] ?? 0;
          _lang = data?['settings']?['language'] ?? 'en';
        });
        print(_lang + ' ==============');

        print("✅ Active Competition: $compTitle");
        print("🎯 Your Score: $userScore");
        print("🏆 Prizes: $compPrizes");

        final query = await FirebaseFirestore.instance
            .collection('users')
            .orderBy("comp", descending: true)
            .limit(23)
            .get();
        setState(() {
          _users = query.docs;
          print(_users);
          _loading = false;
        });
      } else {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        final data = userDoc.data();

        setState(() {
          _lang = data?['settings']?['language'] ?? 'en';
          _loading = false;
        });
        print("❌ No active competition found.");
        print(_lang + ' ==============');
      }
    } catch (e) {
      print("🔥 Error checking competition: $e");
    }

    // Use isExist, compTitle, compPrizes, userScore as needed in your UI or logic
  }

  @override
  void initState() {
    super.initState();
    checkActiveCompetition(FirebaseAuth.instance.currentUser!.uid);
  }

  Widget _buildTop3() {
    if (_users.length < 3) return SizedBox();
    final user1 = _users[0], user2 = _users[1], user3 = _users[2];

    Widget topUser(doc, int rank, double size, Color color) {
      String name = doc['name'] ?? _tr('user');
      int score = doc['comp'] ?? 0;
      return Column(
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: const Color.fromARGB(255, 166, 200, 235),
            child: Icon(Icons.person, color: background, size: size / 2),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '($score) #$rank',
              style: TextStyle(fontSize: 12, color: background),
            ),
          ),
          SizedBox(height: 4),
          Text(
            name.length > 10 ? name.substring(0, 10) + '...' : name,
            style: TextStyle(
              fontWeight: rank == 1 ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        topUser(user2, 2, 40, secondary),
        SizedBox(width: 18),
        topUser(user1, 1, 60, accent),
        SizedBox(width: 18),
        topUser(user3, 3, 40, primary),
      ],
    );
  }

  Widget _buildUserRow(DocumentSnapshot doc, int index) {
    final name = doc['name'] ?? _tr('user');
    final tokens = doc['comp'] ?? 0;
    final rank = index + 1;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: background),
      ),
      title: Text(name, style: TextStyle(color: textColor)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$tokens',
            style: TextStyle(color: secondary, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 12),
          Text('#$rank', style: TextStyle(color: accent)),
        ],
      ),
    );
  }

  Widget _buildPrizeWindow() {
    final accent = Color(0xFFFFD700);
    final background = Color(0xFF2A2A2A);
    final textColor = Colors.white;
    final boxBorderColor = Colors.grey.withOpacity(0.2);
    final cardRadius = BorderRadius.circular(16);

    final prizes = [
      {
        'rank': _tr('firstPlace'),
        'reward':
            '🏆 ' + compPrizes!['1stPlace'].toString() + ' ' + _tr('tokens'),
        'color': Color(0xFFFFD700), // gold
      },
      {
        'rank': _tr('secondPlace'),
        'reward':
            '🥈 ' + compPrizes!['2ndPlace'].toString() + ' ' + _tr('tokens'),
        'color': Color(0xFFC0C0C0), // silver
      },
      {
        'rank': _tr('thirdPlace'),
        'reward':
            '🥉 ' + compPrizes!['3rdPlace'].toString() + ' ' + _tr('tokens'),
        'color': Color(0xFFCD7F32), // bronze
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 12),
            child: Text(
              _tr("prizesForTop3"),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
        ...prizes.map((item) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: background,
              borderRadius: cardRadius,
              border: Border.all(color: boxBorderColor),
              boxShadow: [
                BoxShadow(
                  color: item['color'] as Color,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: item['color'] as Color,
                  child: Text(
                    (item['rank'] as String).substring(0, 2),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['rank'] as String,
                      style: TextStyle(
                        color: item['color'] as Color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      item['reward'] as String,
                      style: TextStyle(color: textColor, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRulesWindow() {
    // Example rules
    final rules = [
      {'textKey': 'acceptRules', 'allowed': true},
      {'textKey': 'useRealId', 'allowed': true},
      {'textKey': 'respectPlayers', 'allowed': true},
      {'textKey': 'inappropriateName', 'allowed': false},
      {'textKey': 'doNotCheat', 'allowed': false},
      {'textKey': 'doNotMultiAccount', 'allowed': false},
      {'textKey': 'dontWinAnotherCompetition', 'allowed': false},
    ];

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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: background,
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rules.map((rule) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        rule['allowed'] as bool
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: rule['allowed'] as bool
                            ? Colors.green
                            : Colors.red,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _tr(rule['textKey'] as String),
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
                  _tr('rules'),
                  style: TextStyle(
                    fontSize: 18,
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
    return _loading
        ? Center(child: CircularProgressIndicator(color: secondary))
        : MainScaffold(
            currentIndex: 2,
            onTab: (i) {
              if (i == 2) return;
              switch (i) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/methods');
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
                  foregroundColor: textColor,
                  title: Text(_tr('leaderboard')),
                  centerTitle: true,
                ),
                body: isExist
                    ? Column(
                        children: [
                          SizedBox(height: 20),
                          _buildTop3(),
                          SizedBox(height: 20),
                          Container(
                            color: Colors.grey[700],
                            height: 50,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min, // Don't stretch
                                children: List.generate(3, (index) {
                                  final icons = [
                                    Icons.supervised_user_circle_outlined,
                                    Icons.add_shopping_cart_sharp,
                                    Icons.checklist_rtl_outlined,
                                  ];
                                  final labels = [
                                    _tr('users'),
                                    _tr('prizes'),
                                    _tr('rules'),
                                  ];
                                  final bools = [
                                    roles['isUser'],
                                    roles['isPrize'],
                                    roles['isRole'],
                                  ];
                                  // final isSelected = _selectedIndex == index;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _selectedIndex = index;
                                          roles['isUser'] = index == 0;
                                          roles['isPrize'] = index == 1;
                                          roles['isRole'] = index == 2;
                                        });
                                      },

                                      icon: Icon(
                                        icons[index],
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        labels[index],
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: TextButton.styleFrom(
                                        backgroundColor: bools[index]!
                                            ? Color(0xFF1E90FF)
                                            : Colors.transparent,
                                        foregroundColor: Color(0xFF1E90FF),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          Divider(color: Colors.white12),
                          Expanded(
                            child: roles['isUser']!
                                ? ListView.builder(
                                    itemCount: _users.length,
                                    itemBuilder: (context, i) => i < 3
                                        ? SizedBox()
                                        : _buildUserRow(_users[i], i),
                                  )
                                : roles['isPrize']!
                                ? ListView(children: [_buildPrizeWindow()])
                                : roles['isRole']!
                                ? ListView(children: [_buildRulesWindow()])
                                : Container(),
                          ),
                        ],
                      )
                    : _buildComingSoon(),
              ),
            ),
          );
  }

  Widget _buildComingSoon() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: 100, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            _tr('competitionComingSoon'),
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            _tr('followUpdatesTelegram'),
            style: TextStyle(fontSize: 16, color: Colors.orangeAccent),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              launchUrl(Uri.parse("https://t.me/freecodeanythink"));
            },
            icon: Icon(Icons.telegram),
            label: Text(_tr("goToTelegram")),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _tr(String key) {
    final isAr = _lang == 'ar';
    switch (key) {
      case 'leaderboard':
        return isAr ? 'لوحة المتصدرين' : 'Leaderboard';
      case 'users':
        return isAr ? 'المستخدمون' : 'Users';
      case 'prizes':
        return isAr ? 'الجوائز' : 'Prizes';
      case 'rules':
        return isAr ? 'القواعد' : 'Rules';
      case 'user':
        return isAr ? 'مستخدم' : 'User';
      case 'tokens':
        return isAr ? 'جواهر' : 'Daimonds';
      case 'firstPlace':
        return isAr ? 'المركز الأول' : '1st Place';
      case 'secondPlace':
        return isAr ? 'المركز الثاني' : '2nd Place';
      case 'thirdPlace':
        return isAr ? 'المركز الثالث' : '3rd Place';
      case 'prizesForTop3':
        return isAr
            ? '🏆 جوائز أفضل\n      ثلاثة مستخدمين'
            : '🏆 The Prizes for the Top\n      Three Users';
      case 'acceptRules':
        return isAr
            ? 'اقبل قوانين المسابقة'
            : 'Accept the rules of the competition';
      case 'useRealId':
        return isAr
            ? 'استخدم معرف فري فاير الحقيقي'
            : 'Use your real Free Fire ID.';
      case 'respectPlayers':
        return isAr ? 'احترم اللاعبين الآخرين' : 'Respect other players.';
      case 'inappropriateName':
        return isAr ? 'لا تستخدم أسماء غير لائقة' : 'Use name inappropriate';
      case 'doNotCheat':
        return isAr
            ? 'لا تغش أو تستغل الثغرات'
            : 'Do not cheat or exploit bugs.';
      case 'doNotMultiAccount':
        return isAr
            ? 'لا تستخدم حسابات متعددة'
            : 'Do not use multiple accounts.';
      case 'dontWinAnotherCompetition':
        return isAr
            ? 'لا تفز في مسابقة أخرى'
            : 'Dont win in another competition';
      case 'competitionComingSoon':
        return isAr ? 'المسابقة قريباً!' : 'Competition coming soon!';
      case 'followUpdatesTelegram':
        return isAr
            ? 'تابع تحديثاتنا على تيليغرام'
            : 'Follow our updates on Telegram';
      case 'goToTelegram':
        return isAr ? 'اذهب إلى تيليغرام' : 'Go to Telegram';
      default:
        return key;
    }
  }
}
