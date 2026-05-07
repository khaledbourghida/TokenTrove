import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:free_fire_app/screens/exchange_screen.dart';
import 'package:free_fire_app/screens/leagueParticipants_screen.dart';
import 'package:free_fire_app/screens/statistics_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _loading = false;
  List? exchangeInfo;

  final _competitionNameController = TextEditingController();
  final _competitionFirstPrizeController = TextEditingController();
  final _competitionSecondPrizeController = TextEditingController();
  final _competitionThirdPrizeController = TextEditingController();
  final _competitionTimeOfEnd = TextEditingController();

  final _leagueNameController = TextEditingController();
  final _leagueTypeController = TextEditingController();
  final _leagueStartController = TextEditingController();
  final _leagueSpotsController = TextEditingController();

  Future<void> createCompetition() async {
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('competitions').add({
        'title': _competitionNameController.text.trim(),
        'prizes': {
          '1stPlace': _competitionFirstPrizeController.text.trim(),
          '2ndPlace': _competitionSecondPrizeController.text.trim(),
          '3rdPlace': _competitionThirdPrizeController.text.trim(),
        },
        'startAt': Timestamp.now(),
        'EndAt': DateTime.parse(_competitionTimeOfEnd.text.trim()),
        'isActive': true,
      });
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final users = await usersCollection.get();

      for (final doc in users.docs) {
        await usersCollection.doc(doc.id).update({"comp": 0});
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Competition created')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> closeAllCompetitions() async {
    setState(() {
      _loading = true;
    });
    final snapshot = await FirebaseFirestore.instance
        .collection('competitions')
        .where('isActive', isEqualTo: true)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.update({'isActive': false});
    }
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'comp': FieldValue.delete()});
    }
    setState(() {
      _loading = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('All competitions closed')));
  }

  Future<void> createLeague() async {
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance.collection('currentLeague').add({
        'name': _leagueNameController.text.trim(),
        'type': _leagueTypeController.text.trim(),
        'startAt': DateTime.parse(_leagueStartController.text.trim()),
        'remaining': int.parse(_leagueSpotsController.text.trim()),
        'createdAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('League created')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> getFirstExchange() async {
    setState(() => _loading = true);
    final querySnapshot = await FirebaseFirestore.instance
        .collection('exchange')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      print('we are here ===========');
      setState(() {
        _loading = false;
        exchangeInfo = [
          doc.data()['diamond'],
          doc.data()['email'],
          doc.data()['ff_id'],
          doc.data()['requiredToken'],
          doc.data()['status'],
          doc.data()['timestamp'],
          doc.data()['uid'],
        ];
      });
      return;
    }
    print('we are here(null)========');
    setState(() {
      _loading = false;
      exchangeInfo = [null, null, null, null, null, null, null];
    });
    return;
  }

  Future<void> viewExchanges() async {
    Navigator.pushNamed(context, '/exchanges');
  }

  Future<void> clearCurrentLeagueAndUserFlags() async {
    setState(() {
      _loading = true;
    });
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      // 🔥 Step 1: Delete all docs inside 'currentLeague' collection
      final currentLeagueDocs = await _firestore
          .collection('currentLeague')
          .get();
      for (final doc in currentLeagueDocs.docs) {
        await _firestore.collection('currentLeague').doc(doc.id).delete();
      }

      print("✅ currentLeague collection cleared");

      // 🔥 Step 2: Remove isRegistered and teamId from all users
      final users = await _firestore.collection('users').get();

      WriteBatch batch = _firestore.batch();
      for (var doc in users.docs) {
        Map<String, dynamic> updates = {};

        if (doc.data().containsKey('isRegistered')) {
          updates['isRegistered'] = FieldValue.delete();
        }

        if (doc.data().containsKey('teamId')) {
          updates['teamId'] = FieldValue.delete();
        }

        if (updates.isNotEmpty) {
          batch.update(doc.reference, updates);
        }
      }

      await batch.commit();
      setState(() {
        _loading = false;
      });
      print("✅ isRegistered and teamId fields removed from users");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('All League removed')));
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print("❌ Error during cleanup: $e");
    }
  }

  @override
  void initState() {
    getFirstExchange();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(color: Colors.white, fontSize: 16);
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Admin Panel'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Competition',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _competitionNameController,
                    style: textStyle,
                    decoration: _inputDecoration("Enter the title"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _competitionFirstPrizeController,
                    style: textStyle,
                    decoration: _inputDecoration("Enter the first prize"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _competitionSecondPrizeController,
                    style: textStyle,
                    decoration: _inputDecoration("Enter the Second prize"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _competitionThirdPrizeController,
                    style: textStyle,
                    decoration: _inputDecoration("Enter the third prize"),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _competitionTimeOfEnd,
                    style: textStyle,
                    decoration: _inputDecoration("End Time (yyyy-MM-dd HH:mm)"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: createCompetition,
                    child: Text('Create Competition'),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Create League',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _leagueNameController,
                    style: textStyle,
                    decoration: _inputDecoration('League Name'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _leagueTypeController,
                    style: textStyle,
                    decoration: _inputDecoration('Type (e.g. , BR, CS)'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _leagueStartController,
                    style: textStyle,
                    decoration: _inputDecoration(
                      'Start Time (yyyy-MM-dd HH:mm)',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _leagueSpotsController,
                    style: textStyle,
                    decoration: _inputDecoration('Spots'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: createLeague,
                    child: Text('Create League'),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'View Exchange Request',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  exchangeWidget(),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ExchangePage()),
                      );
                    },
                    child: Text('View all Exchange Requests'),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.white),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: closeAllCompetitions,
                    child: Text('Close All Competitions'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      clearCurrentLeagueAndUserFlags();
                    },
                    child: Text('Close All League'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LeagueParticipantsPage(),
                        ),
                      );
                    },
                    child: Text('View League Participants'),
                  ),
                  // SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => StatisticsPage()),
                      );
                    },
                    child: Text('View all Statistics Data'),
                  ),
                ],
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hint: Text(hint, style: TextStyle(color: Colors.grey[600])),
    );
  }

  Widget exchangeWidget() {
    if (exchangeInfo?[0] == null) {
      return Container(
        margin: EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 48, 48, 48),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text('No exchange request'),
      );
    }
    int diamond = exchangeInfo?[0];
    String email = exchangeInfo?[1];
    String ff_id = exchangeInfo?[2];
    int requiredToken = exchangeInfo?[3];
    String status = exchangeInfo?[4];
    String uid = exchangeInfo?[6];

    return Container(
      margin: EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 48, 48, 48),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            "Diamond : $diamond",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(height: 10),
          Text(
            "email : $email",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(height: 10),
          Text(
            "ff_id : $ff_id",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(height: 10),
          Text(
            "Tokens : $requiredToken",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(height: 10),
          Text(
            "status : $status",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(height: 10),
          Text(
            "uid : $uid",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
