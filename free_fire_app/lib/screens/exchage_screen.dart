import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({Key? key}) : super(key: key);

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  String _lang = 'en';
  Map<String, dynamic>? exchangeOffre;
  bool loading = false;
  bool isExist = false;

  @override
  void initState() {
    super.initState();
    _fetchLang();
  }

  Future<void> _fetchLang() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      setState(() {
        loading = true;
      });
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final doc2 = await FirebaseFirestore.instance
          .collection('settings')
          .doc('generalSettings')
          .get();
      setState(() {
        _lang = doc.data()?['settings']?['language'] ?? 'en';
        exchangeOffre = doc2.data()?['exchange'];
        isExist = exchangeOffre?['isExist'];
        loading = false;
      });
      print(_lang + ' =============');
    } catch (_) {
      setState(() {
        loading = false;
      });
    }
  }

  void handleDiamondExchangeRequest({
    required BuildContext context,
    required int diamondAmount,
    required int requiredTokens,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr('userNotLoggedIn'))));
      return;
    }

    final uid = user.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr('userDataNotFound'))));
      return;
    }

    final userData = userDoc.data()!;
    final int totalTokens = userData['totalTokenCount'] ?? 0;

    if (totalTokens < requiredTokens) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr('notEnoughTokens'))));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('exchange').add({
        'uid': uid,
        'email': userData['email'],
        'ff_id': userData['ff_id'],
        'requiredToken': requiredTokens,
        'diamond': diamondAmount,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr('exchangeSubmitted'))));

      // Optional: deduct tokens immediately
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'totalTokenCount': FieldValue.increment(-requiredTokens),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_tr('error')}: ${e.toString()}')),
      );
    }
  }

  Future<void> showExchangeConfirmationDialog({
    required BuildContext context,
    required int diamondAmount,
    required int requiredTokens,
    required VoidCallback onConfirm,
  }) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Color(0xFF1E1E1E),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Text(
              _tr('confirmExchange'),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        content: Text(
          _confirmText(requiredTokens, diamondAmount),
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            tooltip: _tr('cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          IconButton(
            icon: Icon(Icons.check_circle, color: Colors.green),
            tooltip: _tr('submit'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog first
              onConfirm(); // Then execute the action
            },
          ),
        ],
      ),
    );
  }

  final primary = Color(0xFFFF4500);
  final secondary = Color(0xFF1E90FF);
  final accent = Color(0xFFFFD700);
  final background = Color(0xFF1C1C1C);
  final cardBg = Color.fromARGB(255, 48, 48, 48);
  final textColor = Color(0xFFF0F0F0);

  List<Map<String, dynamic>> get exchange => [
    {"offre": 100, "tokens": exchangeOffre?['100']},
    {"offre": 210, "tokens": exchangeOffre?['210']},
    {"offre": 530, "tokens": exchangeOffre?['530']},
    {"offre": 645, "tokens": exchangeOffre?['645']},
    {"offre": 1080, "tokens": exchangeOffre?['1080']},
    {"offre": 2200, "tokens": exchangeOffre?['2200']},
    {"offre": 4450, "tokens": exchangeOffre?['4450']},
    {"offre": 6900, "tokens": exchangeOffre?['6900']},
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: loading
          ? Center(child: CircularProgressIndicator(color: secondary))
          : Scaffold(
              backgroundColor: background,
              appBar: AppBar(
                backgroundColor: background,
                iconTheme: IconThemeData(color: Colors.white, size: 35),
                title: Text(
                  _tr('exchangeTitle'),
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
              ),
              body: isExist
                  ? ExchangeUnavailableWidget()
                  : ListView(
                      children: [
                        Column(
                          children: [
                            ...exchange.map((item) {
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      showExchangeConfirmationDialog(
                                        context: context,
                                        diamondAmount: item['offre'] as int,
                                        requiredTokens: item['tokens'] as int,
                                        onConfirm: () {
                                          handleDiamondExchangeRequest(
                                            context: context,
                                            diamondAmount: item['offre'] as int,
                                            requiredTokens:
                                                item['tokens'] as int,
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 8,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: secondary,
                                            child: Icon(Icons.diamond),
                                          ),
                                          SizedBox(width: 16),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${item['offre'] as int} ${_tr('diamonds')}",
                                                style: TextStyle(
                                                  color: secondary,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "${item['tokens'] as int} ${_tr('tokens')}",
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height: 1,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 50,
                                    ),
                                    color: Colors.grey[700],
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget ExchangeUnavailableWidget() {
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
            _tr("exchangeNotAvailable"),
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _tr("exchangeSetup"),
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
      case 'exchangeTitle':
        return isAr ? 'استبدال' : 'Exchange';
      case 'userNotLoggedIn':
        return isAr ? 'المستخدم غير مسجل الدخول' : 'User not logged in';
      case 'userDataNotFound':
        return isAr
            ? 'لم يتم العثور على بيانات المستخدم'
            : 'User data not found';
      case 'notEnoughTokens':
        return isAr ? 'ليست لديك رموز كافية' : 'You don’t have enough tokens';
      case 'exchangeSubmitted':
        return isAr ? 'تم إرسال طلب الاستبدال' : 'Exchange request submitted';
      case 'error':
        return isAr ? 'خطأ' : 'Error';
      case 'confirmExchange':
        return isAr ? 'تأكيد الاستبدال' : 'Confirm Exchange';
      case 'cancel':
        return isAr ? 'إلغاء' : 'Cancel';
      case 'submit':
        return isAr ? 'تأكيد' : 'Submit';
      case 'diamonds':
        return isAr ? 'ألماس' : 'diamonds';
      case 'tokens':
        return isAr ? 'رموز' : 'tokens';
      case 'exchangeNotAvailable':
        return isAr
            ? ' استبدال رموز غير متوفر'
            : 'Exchange tokens not available';
      case 'exchangeSetup':
        return isAr
            ? ' يتم تحديث عملية الإستبدال الآن , حاول لاحقا'
            : 'The exchange process is being updated now, try again later.';
      default:
        return key;
    }
  }

  String _confirmText(int requiredTokens, int diamondAmount) {
    if (_lang == 'ar') {
      return 'هل تريد حقاً استبدال $requiredTokens من الرموز مقابل $diamondAmount من الألماس؟';
    }
    return 'Do you really want to exchange $requiredTokens tokens for $diamondAmount diamonds?';
  }
}
