// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  bool loading = false;
  final user = FirebaseAuth.instance.currentUser;
  String? uid;
  String _lang = 'en';
  bool isExistLink = false;
  bool active = false;
  bool creatingLink = false;
  String shortedLink = 'No link available';
  int _totalVisitors = 0;
  int _usebaleVisitors = 0;
  Map<String, int> _dailyVisitors = {};
  List<Map<String, dynamic>> _diamondOffers = [];

  void fetchData() async {
    setState(() {
      loading = true;
    });
    uid = user!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data();
    final String lang = data?['settings']?['language'] ?? 'en';
    final slug = data?['slug'] ?? 'undefined';

    if (slug == 'undefined') {
      setState(() {
        _lang = lang;
        loading = false;
      });
      return;
    } else {
      final refDoc = await FirebaseFirestore.instance
          .collection('referrals')
          .doc(slug)
          .get();
      if (!refDoc.exists) {
        setState(() {
          _lang = lang;
          loading = false;
        });
        return;
      } else {
        final offersQuery = await FirebaseFirestore.instance
            .collection('diamondOffers')
            .orderBy('order')
            .get();
        setState(() {
          _lang = lang;
          _totalVisitors = data?['totalReferralVisitors'] ?? 0;
          _usebaleVisitors = refDoc.data()?['totalVisitors'];
          _dailyVisitors = Map<String, int>.from(
            refDoc.data()?['dailyVisitors'] ?? {},
          );
          isExistLink = true;
          shortedLink = refDoc.data()?['link'];
          active = refDoc.data()?['active'];
          _diamondOffers = offersQuery.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          loading = false;
        });
        return;
      }
    }
  }

  void createLink() async {
    setState(() {
      creatingLink = true;
    });

    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789qwertyuiopasdfghjklzxcvbnm';
    final rand = Random.secure();

    String getBlock() =>
        List.generate(20, (_) => chars[rand.nextInt(chars.length)]).join();

    String slug = '${getBlock()}';
    String apiToken = '7902b3afd467079aa43850dc0571eef8ac5bdb51';
    String shortingLink =
        'https://coruscating-selkie-75aefa.netlify.app/?slug=${slug}';

    final response = await http.get(
      Uri.parse(
        'https://linkjust.com/api?api=${apiToken}&url=${shortingLink}.com',
      ),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      String link = responseJson['shortenedUrl'];
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'slug': slug,
        'link': link.replaceAll('\\', ''),
        'totalReferralVisitors': 0,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('referrals').doc(slug).set({
        'ownerUid': user!.uid,
        'active': true,
        'createdAt': Timestamp.now(),
        'link': link.replaceAll('\\', ''),
        'totalVisitors': 0,
        'dailyVisitors': {},
      });
      setState(() {
        creatingLink = false;
      });
      fetchData();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${_tr('cantCreateLink')}')));
      setState(() {
        creatingLink = false;
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: shortedLink));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_tr('linkCopied')),
        backgroundColor: Color(0xFF1E90FF),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _claimOffer(Map<String, dynamic> offer) async {
    try {
      if (user == null) return;

      if (_totalVisitors < offer['requiredVisitors']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_tr('notEnoughVisitors')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      final userData = userDoc.data();

      // Create or update referral offer claim
      await FirebaseFirestore.instance.collection('referralOffers').add({
        'uid': user!.uid,
        'name': userData?['name'] ?? 'Unknown',
        'ff_id': userData?['ff_id'] ?? '',
        'numOfVisitors': _totalVisitors,
        'offerId': offer['id'],
        'offerTitle':
            '${offer['requiredVisitors']} ${_tr('visitors')} = ${offer['diamondReward']} ${_tr('diamonds')}',
        'diamondReward': offer['diamondReward'],
        'claimedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Update user's last offer claim
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'lastOfferClaim': FieldValue.serverTimestamp()});
      await FirebaseFirestore.instance
          .collection('referrals')
          .doc(userData?['slug'])
          .update({
            'totalVisitors': _totalVisitors - offer['requiredVisitors'],
          });

      fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('claimed')),
          backgroundColor: Color(0xFFFFD700),
        ),
      );
    } catch (e) {
      print('Error claiming offer: $e');
    }
  }

  Widget _buildVisitorChart() {
    if (_dailyVisitors.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF333333), width: 1),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Color(0xFF666666),
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                'No visitor data available',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Convert string dates to DateTime and sort chronologically
    final sortedEntries =
        _dailyVisitors.entries
            .map((entry) => MapEntry(DateTime.parse(entry.key), entry.value))
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    // Create chart data points
    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
    }).toList();

    // Calculate max value for better scaling
    final maxVisitors = sortedEntries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final chartMaxY = (maxVisitors * 1.2).ceilToDouble();

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: chartMaxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: const Color(0xFF333333), strokeWidth: 0.5);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const Text('');
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                interval: (sortedEntries.length / 3).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sortedEntries.length) {
                    return const Text('');
                  }

                  final date = sortedEntries[index].key;
                  final formattedDate = '${date.month}/${date.day}';

                  return Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: Color(0xFF333333), width: 1),
              bottom: BorderSide(color: Color(0xFF333333), width: 1),
            ),
          ),
          minX: 0,
          maxX: (sortedEntries.length - 1).toDouble(),
          minY: 0,
          maxY: chartMaxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E90FF),
                  Color(0xFF00CED1),
                  Color(0xFFFFD700),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: const Color(0xFFFFFFFF),
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF1E90FF),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E90FF).withOpacity(0.2),
                    const Color(0xFF00CED1).withOpacity(0.1),
                    const Color(0xFFFFD700).withOpacity(0.05),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              // tooltipBackgroundColor: const Color(0xFF2A2A2A),
              tooltipBorderRadius: BorderRadius.all(Radius.circular(8)),
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final index = touchedSpot.x.toInt();
                  if (index < 0 || index >= sortedEntries.length) return null;

                  final date = sortedEntries[index].key;
                  final visitors = touchedSpot.y.toInt();
                  final formattedDate =
                      '${date.month}/${date.day}/${date.year}';

                  return LineTooltipItem(
                    '$formattedDate\n$visitors visitors',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  // Handle touch events if needed
                },
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final progress = _usebaleVisitors / offer['requiredVisitors'];
    final canClaim = progress >= 1.0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF232323),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canClaim ? Color(0xFFFFD700) : Color(0xFF444444),
          width: canClaim ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${offer['requiredVisitors']} ${_tr('visitors')}',
                style: TextStyle(
                  color: Color(0xFFF0F0F0),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${offer['diamondReward']} ${_tr('diamonds')}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Color(0xFF444444),
            valueColor: AlwaysStoppedAnimation<Color>(
              canClaim ? Color(0xFFFFD700) : Color(0xFF1E90FF),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$_usebaleVisitors / ${offer['requiredVisitors']}',
            style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canClaim ? () => _claimOffer(offer) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canClaim
                    ? Color(0xFFFFD700)
                    : Color(0xFF444444),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                canClaim ? _tr('claimOffer') : _tr('notEnoughVisitors'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(
          _tr('referralDashboard'),
          style: TextStyle(
            color: Color(0xFFF0F0F0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF232323),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: secondary))
          : isExistLink
          ? ExistLink()
          : DontExistLink(),
    );
  }

  Widget DontExistLink() {
    final secondary = Color(0xFF1E90FF);
    final textColor = Color(0xFFF0F0F0);
    final subtitleColor = Color(0xFFB0B0B0);
    final cardColor = Color(0xFF2A2A2A);

    return ListView(
      children: [
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main Title
                Text(
                  _tr('titre'),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12),

                // Subtitle
                Text(
                  _tr('subtitle'),
                  style: TextStyle(color: subtitleColor, fontSize: 16),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 32),

                // Referral System Explanation Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF333333), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: secondary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            _tr('howItWorks'),
                            style: TextStyle(
                              color: secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Feature list
                      _buildFeatureItem(
                        Icons.people_outline,
                        _tr('uniqueVisitors'),
                        textColor,
                        subtitleColor,
                      ),
                      SizedBox(height: 12),
                      _buildFeatureItem(
                        Icons.calendar_today_outlined,
                        _tr('dailyTracking'),
                        textColor,
                        subtitleColor,
                      ),
                      SizedBox(height: 12),
                      _buildFeatureItem(
                        Icons.analytics_outlined,
                        _tr('realTimeStats'),
                        textColor,
                        subtitleColor,
                      ),
                      SizedBox(height: 12),
                      _buildFeatureItem(
                        Icons.share_outlined,
                        _tr('easySharing'),
                        textColor,
                        subtitleColor,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Create Link Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: creatingLink
                        ? null
                        : () {
                            createLink();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary,
                      disabledBackgroundColor: secondary.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: creatingLink
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: textColor,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_link, color: textColor, size: 18),
                              SizedBox(width: 8),
                              Text(
                                _tr('buttonText'),
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String text,
    Color textColor,
    Color subtitleColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: subtitleColor, size: 18),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: subtitleColor, fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget ExistLink() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Referral Link Section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF232323), Color(0xFF2A2A2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr('yourReferralLink'),
                  style: TextStyle(
                    color: Color(0xFFF0F0F0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                if (!active)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF4500).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFFF4500)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Color(0xFFFF4500)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _tr('linkInactive'),
                            style: TextStyle(color: Color(0xFFFF4500)),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Activate link logic
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF4500),
                          ),
                          child: Text(_tr('activateLink')),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF444444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            shortedLink,
                            style: TextStyle(
                              color: Color(0xFFF0F0F0),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _copyToClipboard,
                          icon: Icon(Icons.copy, color: Color(0xFF1E90FF)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 24),

          // Stats Section
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E90FF), Color(0xFF4169E1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_totalVisitors',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _tr('totalVisitors'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E90FF), Color(0xFF4169E1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_usebaleVisitors',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _tr('UsebaleVisitors'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Analytics Chart
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF232323),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tr('dailyVisitors'),
                  style: TextStyle(
                    color: Color(0xFFF0F0F0),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildVisitorChart(),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Diamond Offers
          Text(
            _tr('diamondOffers'),
            style: TextStyle(
              color: Color(0xFFF0F0F0),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ..._diamondOffers.map((offer) => _buildOfferCard(offer)),
        ],
      ),
    );
  }

  String _tr(String key) {
    final isAr = _lang == 'ar';
    switch (key) {
      case 'titre':
        return isAr ? 'إنشاء رابط إحالة جديد' : 'Create Your Referral Link';
      case 'subtitle':
        return isAr
            ? 'ابدأ في تتبع الزوار والإحالات الخاصة بك'
            : 'Start tracking your visitors and referrals';
      case 'howItWorks':
        return isAr ? 'كيف يعمل النظام' : 'How It Works';
      case 'uniqueVisitors':
        return isAr
            ? 'تتبع الزوار الفريدين يوميًا - كل مستخدم يُحسب مرة واحدة فقط في اليوم'
            : 'Track unique visitors daily - each user counted only once per day';
      case 'dailyTracking':
        return isAr
            ? 'إحصائيات يومية مفصلة لمراقبة نمو الزوار بمرور الوقت'
            : 'Detailed daily statistics to monitor visitor growth over time';
      case 'realTimeStats':
        return isAr
            ? 'بيانات في الوقت الفعلي مع رسوم بيانية تفاعلية وتحليلات'
            : 'Real-time data with interactive charts and analytics';
      case 'easySharing':
        return isAr
            ? 'شارك رابطك بسهولة عبر جميع المنصات والشبكات الاجتماعية'
            : 'Easily share your link across all platforms and social networks';
      case 'buttonText':
        return isAr ? 'إنشاء الرابط الآن' : 'Create Link Now';
      case 'referralDashboard':
        return isAr ? 'لوحة الإحالة' : 'Referral Dashboard';
      case 'yourReferralLink':
        return isAr ? 'رابط الإحالة الخاص بك' : 'Your Referral Link';
      case 'copyLink':
        return isAr ? 'نسخ الرابط' : 'Copy Link';
      case 'linkCopied':
        return isAr ? 'تم نسخ الرابط!' : 'Link Copied!';
      case 'totalVisitors':
        return isAr ? 'إجمالي الزوار' : 'Total Visitors';
      case 'UsebaleVisitors':
        return isAr ? 'زوار غير مستعمل' : 'Unused visitors';
      case 'dailyVisitors':
        return isAr ? 'الزوار اليوميون' : 'Daily Visitors';
      case 'diamondOffers':
        return isAr ? 'عروض الماس' : 'Diamond Offers';
      case 'visitors':
        return isAr ? 'زائر' : 'Visitors';
      case 'diamonds':
        return isAr ? 'ماسة' : 'Diamonds';
      case 'claimOffer':
        return isAr ? 'استلام العرض' : 'Claim Offer';
      case 'claimed':
        return isAr
            ? 'تم المطالبة بطلبك، وسيتم مراجعته، وسنرد عليك في أقرب وقت ممكن'
            : 'Claimed , your request in review , we will reponre as soon as possible';
      case 'notEnoughVisitors':
        return isAr ? 'عدد الزوار غير كافي' : 'Not Enough Visitors';
      case 'linkInactive':
        return isAr ? 'الرابط غير نشط' : 'Link Inactive';
      case 'activateLink':
        return isAr ? 'تفعيل الرابط' : 'Activate Link';
      default:
        return key;
    }
  }
}
