import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:free_fire_app/screens/referral_screen.dart';
import 'package:free_fire_app/screens/tokens_screen.dart';
import 'package:free_fire_app/widgets/main_scaffold.dart';

class EarnmethodScreen extends StatefulWidget {
  const EarnmethodScreen({super.key});

  @override
  State<EarnmethodScreen> createState() => _EarnmethodScreenState();
}

class _EarnmethodScreenState extends State<EarnmethodScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String _lang = 'en';
  bool loading = false;

  void fetchData() async {
    setState(() {
      loading = true;
    });

    final uid = user!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();

    final String lang = data?['settings']?['language'] ?? 'en';

    setState(() {
      _lang = lang;
      loading = false;
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Color(0xFF1E90FF);
    final background = Color(0xFF1C1C1C);
    final textColor = Color(0xFFF0F0F0);
    return loading
        ? Center(child: CircularProgressIndicator(color: secondary))
        : MainScaffold(
            currentIndex: 1,
            onTab: (i) {
              if (i == 1) return;
              switch (i) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
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
                appBar: AppBar(backgroundColor: background),
                backgroundColor: background,
                body: ListView(
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Text(
                            _tr('EarningMethod'),
                            style: TextStyle(color: textColor, fontSize: 25),
                          ),
                        ),
                        SizedBox(height: 50),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: secondary,
                                  border: Border.all(width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: Icon(
                                  Icons.ads_click,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _tr('watchads'),
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          205,
                                          204,
                                          204,
                                        ),
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _tr('watchadsinfo'),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontFamily: 'Roboco',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TokensScreen(),
                                    ),
                                  );
                                },
                                child: Icon(
                                  _lang == 'ar'
                                      ? Icons.chevron_left
                                      : Icons.chevron_right,
                                  size: 50,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 1,
                          margin: EdgeInsets.symmetric(horizontal: 50),
                          color: Colors.grey[700],
                        ),
                        SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: secondary,
                                  border: Border.all(width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: Icon(
                                  Icons.link,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _tr('getlink'),
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          205,
                                          204,
                                          204,
                                        ),
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _tr('getlinkinfo'),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontFamily: 'Roboco',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (_) => ReferralDashboard(),
                                  //   ),
                                  // );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${_tr('invalideFeature')}',
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(
                                  _lang == 'ar'
                                      ? Icons.chevron_left
                                      : Icons.chevron_right,
                                  size: 50,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 1,
                          margin: EdgeInsets.symmetric(horizontal: 50),
                          color: Colors.grey[700],
                        ),
                        SizedBox(height: 20),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: secondary,
                                  border: Border.all(width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: Icon(
                                  Icons.share_sharp,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _tr('referral'),
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          205,
                                          204,
                                          204,
                                        ),
                                        fontSize: 20,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      _tr('referralinfo'),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontFamily: 'Roboco',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReferralScreen(),
                                    ),
                                  );
                                },
                                child: Icon(
                                  _lang == 'ar'
                                      ? Icons.chevron_left
                                      : Icons.chevron_right,
                                  size: 50,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  String _tr(String key) {
    final isAr = _lang == 'ar';
    switch (key) {
      case 'EarningMethod':
        return isAr ? 'طرق الربح' : 'Earning Method';
      case 'watchads':
        return isAr ? 'مشاهدة الإعلانات' : 'Watch Ads';
      case 'watchadsinfo':
        return isAr
            ? 'شاهد الإعلانات واحصل على الرموز المميزة'
            : 'watch ads and get tokens';
      case 'getlink':
        return isAr ? 'الحصول على الروابط' : 'Get Links';
      case 'getlinkinfo':
        return isAr
            ? 'انقر على الروابط واحصل على الرموز المميزة'
            : 'click links and get tokens';
      case 'referral':
        return isAr ? 'رابط الإحالة' : 'Referral link';
      case 'referralinfo':
        return isAr ? 'احصل على رابطك الخاص' : 'get your own link';
      case 'invalideFeature':
        return isAr
            ? 'نحن نعمل على تطبيق هذه الميزة، ابق على اطلاع'
            : 'We work to implement this feature , stay tained';
      default:
        return key;
    }
  }
}
