import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeagueParticipantsPage extends StatefulWidget {
  const LeagueParticipantsPage({Key? key}) : super(key: key);

  @override
  _LeagueParticipantsPageState createState() => _LeagueParticipantsPageState();
}

class _LeagueParticipantsPageState extends State<LeagueParticipantsPage> {
  late Future<List<Map<String, dynamic>>> _participantsFuture;

  @override
  void initState() {
    super.initState();
    _participantsFuture = _fetchParticipants();
  }

  Future<List<Map<String, dynamic>>> _fetchParticipants() async {
    final firestore = FirebaseFirestore.instance;

    // Get the single current league doc
    final leagueSnapshot = await firestore.collection('currentLeague').get();
    if (leagueSnapshot.docs.isEmpty) {
      return [];
    }

    final leagueDoc = leagueSnapshot.docs.first;
    final participantsRef = leagueDoc.reference.collection('participants');
    final participantsSnapshot = await participantsRef.get();

    List<Map<String, dynamic>> teams = [];

    for (final doc in participantsSnapshot.docs) {
      teams.add({'teamName': doc.id, 'members': doc.data()});
    }

    return teams;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text("League Participants"),
        backgroundColor: Color(0xFF1E90FF),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _participantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No teams registered.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final teams = snapshot.data!;

          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final teamName = team['teamName'];
              final members = team['members'] as Map<String, dynamic>;

              return Container(
                margin: EdgeInsets.all(10),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 48, 48, 48),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Team: $teamName",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    ..._buildMemberList(members),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildMemberList(Map<String, dynamic> members) {
    List<Widget> widgets = [];
    final keys = members.keys.toList();

    // Expecting keys like member1Name, member1FFID, etc.
    for (int i = 1; i <= 5; i++) {
      final nameKey = 'member${i}Name';
      final idKey = 'member${i}FFID';

      if (members.containsKey(nameKey) && members.containsKey(idKey)) {
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "• ${members[nameKey]} (${members[idKey]})",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 4),
            ],
          ),
        );
      }
    }

    return widgets;
  }
}
