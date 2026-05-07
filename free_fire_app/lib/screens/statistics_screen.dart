import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int totalUsers = 0;
  int totalExchanges = 0;
  int pendingExchanges = 0;
  num totalAdsWatched = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    setState(() => isLoading = true);

    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      final exchangesSnapshot = await FirebaseFirestore.instance
          .collection('exchange')
          .get();

      final adsCount = usersSnapshot.docs.fold<num>(0, (sum, doc) {
        final data = doc.data();
        return sum + (data['totalTokenCount'] ?? 0)!;
      });

      final pendingCount = exchangesSnapshot.docs
          .where((doc) => doc['status'] == 'pending')
          .length;

      setState(() {
        totalUsers = usersSnapshot.docs.length;
        totalExchanges = exchangesSnapshot.docs.length;
        pendingExchanges = pendingCount;
        totalAdsWatched = adsCount;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching stats: $e");
      setState(() => isLoading = false);
    }
  }

  String formatNumber(int number) {
    final formatter = NumberFormat.compact();
    return formatter.format(number);
  }

  Widget buildCard(String title, var value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: color),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Text(
                formatNumber(value),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: Color(0xFF232323),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Statistics', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchStatistics,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : RefreshIndicator(
              onRefresh: fetchStatistics,
              child: ListView(
                padding: EdgeInsets.all(12),
                children: [
                  buildCard(
                    'Total Users',
                    totalUsers,
                    Icons.person,
                    Colors.blueAccent,
                  ),
                  buildCard(
                    'Total Exchanges',
                    totalExchanges,
                    Icons.monetization_on,
                    Colors.amber,
                  ),
                  buildCard(
                    'Pending Exchanges',
                    pendingExchanges,
                    Icons.pending_actions,
                    Colors.redAccent,
                  ),
                  buildCard(
                    'Total Ads Watched',
                    totalAdsWatched,
                    Icons.remove_red_eye,
                    Colors.greenAccent,
                  ),
                ],
              ),
            ),
    );
  }
}
