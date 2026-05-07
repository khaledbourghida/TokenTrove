import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:free_fire_app/screens/pannel_screen.dart';
import 'package:free_fire_app/screens/profileInfo_screen.dart';
import 'package:free_fire_app/widgets/main_scaffold.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isOn1 = false;
  bool _isOn2 = true;
  bool loading = false;
  bool isAdmine = false;
  String _lang = 'en';

  Future checkRole() async {
    setState(() {
      loading = true;
    });
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final role = userDoc.data()?['role'] ?? "user";
    print('=================$role');

    if (role == 'admin') {
      setState(() {
        loading = false;
        isAdmine = true;
        _lang = userDoc.data()?['settings']?['language'] ?? 'en';
      });
      print('==========$isAdmine');
    } else {
      setState(() {
        loading = false;
        isAdmine = false;
        _lang = userDoc.data()?['settings']?['language'] ?? 'en';
      });
    }

    print('==========$isAdmine');
    print(_lang + ' ===========');
  }

  final primary = Color(0xFFFF4500);
  final secondary = Color(0xFF1E90FF);
  final accent = Color(0xFFFFD700);
  final background = Color(0xFF1C1C1C);
  final cardBg = Color(0xFF232323);
  final textColor = Color(0xFFF0F0F0);

  Future<void> _saveLanguageToFirestore(String uid, String langCode) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'settings': {'language': langCode},
      }, SetOptions(merge: true));
    } catch (e) {
      print('Failed to save language: $e');
    }
  }

  @override
  void initState() {
    checkRole();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator(color: secondary))
        : MainScaffold(
            currentIndex: 4,
            onTab: (i) {
              if (i == 4) return;
              switch (i) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/methods');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/leaderbord');
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, '/league');
                  break;
              }
            },
            child: Directionality(
              textDirection: _lang == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: background,
                appBar: AppBar(backgroundColor: background),
                body: ListView(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 10),
                        Container(
                          margin: EdgeInsetsDirectional.only(end: 30),
                          child: Text(
                            _tr('profileAndSettings'),
                            style: TextStyle(
                              color: const Color.fromARGB(255, 213, 214, 214),
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 60),
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
                                  Icons.notifications,
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
                                      _tr('notifications'),
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
                                      _tr('activateNotifications'),
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
                              Switch(
                                value: _isOn1,
                                onChanged: (val) {
                                  setState(() {
                                    _isOn1 = val;
                                  });

                                  // Optional: do something with the state
                                  print("Switch state: $_isOn1");
                                },
                                activeColor: secondary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: background,
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
                                  Icons.dark_mode,
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
                                      _tr('darkMode'),
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
                                      _tr('changeAppearance'),
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
                              Switch(
                                value: _isOn2,
                                onChanged: (val) {
                                  // setState(() {
                                  //   _isOn2 = val;
                                  // });

                                  // Optional: do something with the state
                                  print("Switch state: $_isOn2");
                                },
                                activeColor: secondary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: background,
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
                                  Icons.language,
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
                                      _tr('languages'),
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
                                      _tr('selectYourLanguages'),
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
                                onTap: () async {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user == null) return;

                                  // Get current selected language
                                  final doc = await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .get();
                                  final currentLang =
                                      doc.data()?['settings']?['language'] ??
                                      'en';

                                  await showDialog(
                                    context: context,
                                    builder: (context) {
                                      String selectedLang = currentLang;

                                      return StatefulBuilder(
                                        builder: (context, setDialogState) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            backgroundColor: Color(0xFF2A2A2A),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _tr('selectLanguage'),
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  _buildLanguageTile(
                                                    context,
                                                    lang: 'English',
                                                    code: 'en',
                                                    selected:
                                                        selectedLang == 'en',
                                                    onSelect: () async {
                                                      setDialogState(
                                                        () =>
                                                            selectedLang = 'en',
                                                      );
                                                      await _saveLanguageToFirestore(
                                                        user.uid,
                                                        'en',
                                                      );
                                                      setState(() {
                                                        _lang = 'en';
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  const SizedBox(height: 12),
                                                  _buildLanguageTile(
                                                    context,
                                                    lang: 'العربية',
                                                    code: 'ar',
                                                    selected:
                                                        selectedLang == 'ar',
                                                    // disabled: true,
                                                    onSelect: () async {
                                                      setDialogState(
                                                        () =>
                                                            selectedLang = 'ar',
                                                      );
                                                      await _saveLanguageToFirestore(
                                                        user.uid,
                                                        'ar',
                                                      );
                                                      setState(() {
                                                        _lang = 'ar';
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
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
                                  Icons.info,
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
                                      _tr('editProfile'),
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
                                      _tr('changeYourInfo'),
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
                                      builder: (_) => ProfileInfoScreen(),
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
                                  Icons.logout,
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
                                      _tr('logout'),
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
                                      _tr('logoutFromApp'),
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
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
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
                        !isAdmine
                            ? Container()
                            : Container(
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
                                        Icons.admin_panel_settings,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _tr('panelPage'),
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
                                            _tr('trackAppInfo'),
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
                                            builder: (_) => AdminPanelScreen(),
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
                        SizedBox(height: 30),
                        Center(
                          child: Text(
                            '$version',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String lang,
    required String code,
    required bool selected,
    bool disabled = false,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: disabled ? null : onSelect,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: disabled ? Colors.white10 : Colors.white24,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              lang,
              style: TextStyle(
                color: Colors.white.withOpacity(disabled ? 0.3 : 1.0),
                fontSize: 16,
              ),
            ),
            if (selected && !disabled)
              Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  String _tr(String key) {
    final isAr = _lang == 'ar';
    switch (key) {
      case 'profileAndSettings':
        return isAr ? 'الملف الشخصي والإعدادات' : 'Profile & Settings';
      case 'notifications':
        return isAr ? 'الإشعارات' : 'Notification';
      case 'activateNotifications':
        return isAr ? 'فعّل الإشعارات' : 'Activate the notifications';
      case 'darkMode':
        return isAr ? 'الوضع الداكن' : 'Dark Mode';
      case 'changeAppearance':
        return isAr ? 'غيّر المظهر' : 'Change the appearance';
      case 'languages':
        return isAr ? 'اللغات' : 'Languages';
      case 'selectYourLanguages':
        return isAr ? 'اختر لغتك' : 'Select your languages';
      case 'selectLanguage':
        return isAr ? 'اختر اللغة' : 'Select Language';
      case 'editProfile':
        return isAr ? 'تعديل الملف الشخصي' : 'Edit profile';
      case 'changeYourInfo':
        return isAr ? 'غيّر معلوماتك' : 'change your information';
      case 'logout':
        return isAr ? 'تسجيل الخروج' : 'Log out';
      case 'logoutFromApp':
        return isAr ? 'تسجيل الخروج من التطبيق' : 'Log out from the app';
      case 'panelPage':
        return isAr ? 'صفحة اللوحة' : 'Panel Page';
      case 'trackAppInfo':
        return isAr ? 'تتبّع معلومات التطبيق' : 'Track the app info';
      default:
        return key;
    }
  }
}
