import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:free_fire_app/widgets/main_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class LeageScreen extends StatefulWidget {
  const LeageScreen({Key? key}) : super(key: key);

  @override
  State<LeageScreen> createState() => _LeageScreenState();
}

class _LeageScreenState extends State<LeageScreen> {
  bool isIndividual = true;
  final _ffIdController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _friend1Controller = TextEditingController();
  final _friend2Controller = TextEditingController();
  final _friend3Controller = TextEditingController();
  bool isRegisterComplete = false;
  Timer? _timer;
  DateTime? _startAt;
  bool isRegister = false;
  String teamId = "";
  String _lang = 'en';

  Future<void> registerIndividual({
    required String leagueId,
    required String ffId,
    required String teamName,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        isRegisterComplete = !isRegisterComplete;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr("userNotLoggedIn"))));
      return;
    }

    if (_ffIdController.text == "" || _teamNameController.text == "") {
      setState(() {
        isRegisterComplete = !isRegisterComplete;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr("fillAllFields"))));
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userSnap = await userRef.get();
    final leagueRef = FirebaseFirestore.instance
        .collection('currentLeague')
        .doc(leagueId);
    final participantsRef = leagueRef.collection('participants');

    if (userSnap.data()?['ff_id'] != _ffIdController.text) {
      setState(() {
        isRegisterComplete = !isRegisterComplete;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr("wrongFfId"))));
      return;
    }

    if (userSnap.data()?['isRegistered'] == true) {
      setState(() {
        isRegisterComplete = !isRegisterComplete;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr("alreadyRegistered"))));
      return;
    }

    // Try to join an existing team with less than 4 members
    final teamsSnapshot = await participantsRef.get();
    for (var doc in teamsSnapshot.docs) {
      final members = doc.data()['members'] as List<dynamic>;
      if (members.length < 4) {
        await participantsRef.doc(doc.id).update({
          'members': FieldValue.arrayUnion([
            {'uid': uid, 'ff_id': ffId, 'name': userSnap.data()?['name']},
          ]),
        });

        await userRef.set({
          'isRegistered': true,
          'teamId': doc.id,
        }, SetOptions(merge: true));

        await leagueRef.update({'remainingSpots': FieldValue.increment(-1)});

        setState(() {
          isRegisterComplete = !isRegisterComplete;
        });

        return;
      }
    }

    // If no available team found, create a new team with the provided name
    final newTeamDoc = participantsRef.doc(teamName);
    final newTeamExists = await newTeamDoc.get();
    if (newTeamExists.exists) {
      setState(() {
        isRegisterComplete = !isRegisterComplete;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr("teamNameExists"))));
      return;
    }

    await newTeamDoc.set({
      'name': teamName,
      'createdAt': Timestamp.now(),
      'members': [
        {'uid': uid, 'ff_id': ffId, 'name': userSnap.data()?['name']},
      ],
    });

    await userRef.set({
      'isRegistered': true,
      'teamId': teamName,
    }, SetOptions(merge: true));

    await leagueRef.update({'remaining': FieldValue.increment(-1)});
    setState(() {
      isRegisterComplete = !isRegisterComplete;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_tr("teamCreated"))));
  }

  Future<void> registerTeam({
    required String leagueId,
    required String teamName,
    required List<String> ffIds,
  }) async {
    if (ffIds[0] == "" || teamName == "" || ffIds[1] == "") {
      setState(() {
        isRegisterComplete = !isRegisterComplete;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr("fillAllFields"))));
      return;
    }

    final usersRef = FirebaseFirestore.instance.collection('users');
    final leagueRef = FirebaseFirestore.instance
        .collection('currentLeague')
        .doc(leagueId);
    final participantsRef = leagueRef.collection('participants');

    // Check if team name already exists
    final existingTeam = await participantsRef.doc(teamName).get();
    if (existingTeam.exists) {
      setState(() {
        isRegisterComplete = !isRegisterComplete;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_tr("teamNameTaken"))));
      return;
    }

    List<String> ffIdsReal = [];

    for (String ffid in ffIds) {
      if (ffid != "") {
        ffIdsReal.add(ffid);
      }
    }

    List<Map<String, dynamic>> memberData = [];

    for (final ffId in ffIdsReal) {
      final query = await usersRef
          .where('ff_id', isEqualTo: ffId)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        setState(() {
          isRegisterComplete = !isRegisterComplete;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_userNotUsingApp(ffId))));
        return;
      }

      final userDoc = query.docs.first;
      final user = userDoc.data();
      final uid = userDoc.id;

      if (user['isRegistered'] == true) {
        setState(() {
          isRegisterComplete = !isRegisterComplete;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_userAlreadyRegistered(user['name'] ?? ''))),
        );
        return;
      }

      memberData.add({'uid': uid, 'ff_id': ffId, 'name': user['name']});
    }

    // Create the new team
    await participantsRef.doc(teamName).set({
      'name': teamName,
      'createdAt': Timestamp.now(),
      'members': memberData,
    });

    // Update each member's user doc
    for (var member in memberData) {
      await usersRef.doc(member['uid']).set({
        'isRegistered': true,
        'teamId': teamName,
      }, SetOptions(merge: true));
    }

    await leagueRef.update({
      'remaining': FieldValue.increment(-memberData.length),
    });
    setState(() {
      isRegisterComplete = !isRegisterComplete;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_tr("teamCreated"))));
  }

  Future<void> _isRegister() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final data = userDoc.data();
    setState(() {
      isRegister = data?['isRegistered'] ?? false;
      teamId = data?['teamId'] ?? " ";
      _lang = data?['settings']?['language'] ?? 'en';
    });
    print(_lang + ' ===================');
  }

  @override
  void initState() {
    super.initState();
    _isRegister();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 3,
      onTab: (i) {
        if (i == 3) return;
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
          case 4:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      child: Directionality(
        textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF1C1C1C),
            foregroundColor: Colors.white,
            title: Text(_tr('league')),
            centerTitle: true,
          ),
          backgroundColor: Color(0xFF1C1C1C),
          body: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('currentLeague')
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                // No current league
                return _buildComingSoon();
              }

              final leagueData =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;
              final leagueId = snapshot.data!.docs.first.id;
              final startAt = leagueData['startAt']?.toDate();
              if (_startAt == null && startAt != null) {
                // Store startAt in state only once
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _startAt = startAt;
                  });
                });
              }
              return isRegister
                  ? _isRegisterWidget()
                  : _buildLeagueContent(leagueData, leagueId);
            },
          ),
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
            _tr('leagueComingSoon'),
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

  Widget _buildLeagueContent(Map<String, dynamic> leagueData, String leagueId) {
    final type = leagueData['type'] ?? 'Unknown';
    final remaining = leagueData['remaining'] ?? 0;
    // final createdAt = leagueData['createdAt']?.toDate();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              _tr('leagueType') + ': ' + type.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
          SizedBox(height: 10),
          Card(
            shadowColor: Color.fromARGB(255, 15, 15, 15),
            color: Color(0xFF1C1C1C),
            child: ListTile(
              title: Text(
                _tr("remainingSpots") + ' :',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
              trailing: Text(
                '$remaining',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          ),
          SizedBox(height: 10),
          if (_startAt != null) CountdownTimerWidget(startAt: _startAt!),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeButton(true),
              SizedBox(width: 16),
              _buildModeButton(false),
            ],
          ),
          SizedBox(height: 20),
          isIndividual
              ? _buildIndividualForm(leagueId)
              : _buildTeamForm(leagueId),
        ],
      ),
    );
  }

  Widget _buildModeButton(bool individual) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isIndividual == individual
            ? Colors.orange
            : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          isIndividual = individual;
        });
      },
      child: Row(
        children: [
          Icon(individual ? Icons.person : Icons.group),
          SizedBox(width: 8),
          Text(individual ? _tr('individual') : _tr('team')),
        ],
      ),
    );
  }

  Widget _buildIndividualForm(String leagueId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ffIdController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: _tr('yourFreeFireId'),
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _teamNameController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: _tr('preferredTeamName'),
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        Text(
          _tr('placeOrCreate'),
          style: TextStyle(color: Colors.red, fontSize: 13),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isRegisterComplete = !isRegisterComplete;
            });
            registerIndividual(
              leagueId: leagueId,
              ffId: _ffIdController.text,
              teamName: _teamNameController.text,
            );
          },
          child: Text(_tr('register')),
        ),
        SizedBox(height: 20),
        Center(
          child: isRegisterComplete ? CircularProgressIndicator() : Container(),
        ),
      ],
    );
  }

  Widget _buildTeamForm(String leagueId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _teamNameController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: _tr('teamName'),
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        _buildMemberField(_ffIdController, _tr('yourFfId')),
        _buildMemberField(_friend1Controller, _tr('friend1FfId')),
        _buildMemberField(_friend2Controller, _tr('friend2FfIdOptional')),
        _buildMemberField(_friend3Controller, _tr('friend3FfIdOptional')),
        SizedBox(height: 10),
        Text(
          _tr('allMembersMustHaveAccount'),
          style: TextStyle(color: Colors.red, fontSize: 13),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isRegisterComplete = !isRegisterComplete;
            });
            registerTeam(
              leagueId: leagueId,
              teamName: _teamNameController.text,
              ffIds: [
                _ffIdController.text,
                _friend1Controller.text,
                _friend2Controller.text,
                _friend3Controller.text,
              ],
            );
          },
          child: Text(_tr('registerTeam')),
        ),
        SizedBox(height: 20),
        Center(
          child: isRegisterComplete ? CircularProgressIndicator() : Container(),
        ),
      ],
    );
  }

  Widget _buildMemberField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _isRegisterWidget() {
    return Center(
      child: Column(
        children: [
          if (_startAt != null) CountdownTimerWidget(startAt: _startAt!),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF1E90FF), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, color: Colors.greenAccent, size: 48),
                  SizedBox(height: 16),
                  Text(
                    _tr('alreadyRegisteredTitle'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    _tr('yourTeam') + ': ' + teamId,
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _tr('weWillNotify'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ffIdController.dispose();
    _teamNameController.dispose();
    _friend1Controller.dispose();
    _friend2Controller.dispose();
    _friend3Controller.dispose();
    // _friend4Controller.dispose();
    _timer?.cancel();
    super.dispose();
  }
}

// CountdownTimerWidget displays the countdown without rebuilding the parent
class CountdownTimerWidget extends StatefulWidget {
  final DateTime startAt;
  const CountdownTimerWidget({Key? key, required this.startAt})
    : super(key: key);

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateRemaining());
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final diff = widget.startAt.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (days > 0) {
      return "$days d : " +
          hours.toString().padLeft(2, '0') +
          " h : " +
          minutes.toString().padLeft(2, '0') +
          " m : " +
          seconds.toString().padLeft(2, '0') +
          " s";
    } else {
      return hours.toString().padLeft(2, '0') +
          " h : " +
          minutes.toString().padLeft(2, '0') +
          " m : " +
          seconds.toString().padLeft(2, '0') +
          " s";
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF1E90FF), width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatDuration(_remaining),
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Localization helpers
extension on _LeageScreenState {
  String _tr(String key) {
    final isAr = _lang == 'ar';
    switch (key) {
      case 'league':
        return isAr ? 'الدوري' : 'League';
      case 'leagueComingSoon':
        return isAr ? 'الدوري قريباً!' : 'League coming soon!';
      case 'followUpdatesTelegram':
        return isAr
            ? 'تابع تحديثاتنا على تيليغرام'
            : 'Follow our updates on Telegram';
      case 'goToTelegram':
        return isAr ? 'اذهب إلى تيليغرام' : 'Go to Telegram';
      case 'leagueType':
        return isAr ? 'نوع الدوري' : 'League Type';
      case 'remainingSpots':
        return isAr ? 'المقاعد المتبقية' : 'Remaining Spots';
      case 'individual':
        return isAr ? 'فردي' : 'Individual';
      case 'team':
        return isAr ? 'فريق' : 'Team';
      case 'yourFreeFireId':
        return isAr ? 'معرف فري فاير الخاص بك' : 'Your Free Fire ID';
      case 'preferredTeamName':
        return isAr ? 'اسم الفريق المفضل' : 'Preferred Team Name';
      case 'placeOrCreate':
        return isAr
            ? '* سنقوم بوضعك في فريق موجود أو إنشاء فريق إذا لزم الأمر.'
            : '* We will place you in an existing team or create one if needed.';
      case 'register':
        return isAr ? 'سجّل' : 'Register';
      case 'teamName':
        return isAr ? 'اسم الفريق' : 'Team Name';
      case 'yourFfId':
        return isAr ? 'معرّفك في فري فاير' : 'Your FF ID';
      case 'friend1FfId':
        return isAr ? 'معرّف صديق 1' : 'Friend 1 FF ID';
      case 'friend2FfIdOptional':
        return isAr ? 'معرّف صديق 2 (اختياري)' : 'Friend 2 FF ID (Optional)';
      case 'friend3FfIdOptional':
        return isAr ? 'معرّف صديق 3 (اختياري)' : 'Friend 3 FF ID (Optional)';
      case 'allMembersMustHaveAccount':
        return isAr
            ? '* يجب أن يمتلك جميع الأعضاء حساباً في التطبيق للمشاركة.'
            : '* All members must have an account in the app to participate.';
      case 'registerTeam':
        return isAr ? 'تسجيل الفريق' : 'Register Team';
      case 'alreadyRegisteredTitle':
        return isAr ? 'أنت مسجّل بالفعل!' : 'You are already registered!';
      case 'yourTeam':
        return isAr ? 'فريقك' : 'Your team';
      case 'weWillNotify':
        return isAr
            ? 'سنقوم بإعلامك بتحديثات الدوري.\nتأكد من جاهزيتك!'
            : 'We will notify you with the league updates.\nMake sure you’re ready!';
      case 'userNotLoggedIn':
        return isAr ? 'المستخدم غير مسجل الدخول.' : 'User not logged in.';
      case 'fillAllFields':
        return isAr ? 'يرجى ملء جميع الحقول.' : 'Fill all the text fields';
      case 'wrongFfId':
        return isAr
            ? 'معرف فري فاير غير صحيح، عدّله أو حدّث المعرف الحالي.'
            : 'Your FF ID is wrong, fix it or update your current ID';
      case 'alreadyRegistered':
        return isAr ? 'أنت مسجّل بالفعل.' : 'You are already registered.';
      case 'teamNameExists':
        return isAr
            ? 'اسم الفريق موجود مسبقاً. اختر اسماً آخر.'
            : 'Team name already exists. Please choose another.';
      case 'teamNameTaken':
        return isAr
            ? 'اسم الفريق مأخوذ. اختر اسماً آخر.'
            : 'Team name already taken. Choose another.';
      case 'teamCreated':
        return isAr ? 'تم إنشاء الفريق بنجاح' : 'Team created successful';
      default:
        return key;
    }
  }

  String _userNotUsingApp(String ffId) {
    final isAr = _lang == 'ar';
    return isAr
        ? 'المستخدم ذو معرف فري فاير $ffId لا يستخدم التطبيق.'
        : 'User with FF ID $ffId is not using the app.';
  }

  String _userAlreadyRegistered(String name) {
    final isAr = _lang == 'ar';
    return isAr
        ? 'المستخدم $name مسجّل بالفعل.'
        : 'User $name is already registered.';
  }
}
