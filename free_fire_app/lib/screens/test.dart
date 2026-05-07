import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'dart:math';

class ReferralDashboard extends StatefulWidget {
  @override
  _ReferralDashboardState createState() => _ReferralDashboardState();
}

class _ReferralDashboardState extends State<ReferralDashboard>
    with TickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _lang = 'en';
  bool _isLoading = true;
  String? _referralLink;
  bool _isLinkActive = false;
  int _totalVisitors = 0;
  Map<String, int> _dailyVisitors = {};
  List<Map<String, dynamic>> _diamondOffers = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Load user settings
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _lang = userDoc.data()?['settings']?['language'] ?? 'en';
          _totalVisitors = userDoc.data()?['totalReferralVisitors'] ?? 0;
        });
      }

      // Load referral data
      final referralQuery = await _firestore
          .collection('referrals')
          .where('ownerUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (referralQuery.docs.isNotEmpty) {
        final referralDoc = referralQuery.docs.first;
        final data = referralDoc.data();
        setState(() {
          _referralLink = data['link'];
          _isLinkActive = data['active'] ?? false;
          _totalVisitors = data['totalVisitors'] ?? 0;
          _dailyVisitors = Map<String, int>.from(data['dailyVisitors'] ?? {});
        });
      }

      // Load diamond offers
      final offersQuery = await _firestore
          .collection('diamondOffers')
          .orderBy('order')
          .get();

      setState(() {
        _diamondOffers = offersQuery.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  String _tr(String key) {
    final isAr = _lang == 'ar';
    switch (key) {
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
        return isAr ? 'تم الاستلام' : 'Claimed';
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

  void _copyToClipboard() {
    if (_referralLink != null) {
      Clipboard.setData(ClipboardData(text: _referralLink!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('linkCopied')),
          backgroundColor: Color(0xFF1E90FF),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _claimOffer(Map<String, dynamic> offer) async {
    try {
      final user = _auth.currentUser;
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
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      // Create or update referral offer claim
      await _firestore.collection('referralOffers').add({
        'uid': user.uid,
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
      await _firestore.collection('users').doc(user.uid).update({
        'lastOfferClaim': FieldValue.serverTimestamp(),
      });

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
        child: Center(
          child: Text(
            'No visitor data yet',
            style: TextStyle(color: Color(0xFFF0F0F0)),
          ),
        ),
      );
    }

    final sortedEntries = _dailyVisitors.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
    }).toList();

    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [Color(0xFF1E90FF), Color(0xFFFFD700)],
              ),
              barWidth: 3,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E90FF).withOpacity(0.3),
                    Color(0xFFFFD700).withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final progress = _totalVisitors / offer['requiredVisitors'];
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
            '$_totalVisitors / ${offer['requiredVisitors']}',
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
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Color(0xFF1C1C1C),
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
        ),
        body: _isLoading
            ? Center(
                child: Shimmer.fromColors(
                  baseColor: Color(0xFF444444),
                  highlightColor: Color(0xFF666666),
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: EdgeInsets.all(16),
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
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
                          if (!_isLinkActive)
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
                                      style: TextStyle(
                                        color: Color(0xFFFF4500),
                                      ),
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
                                      _referralLink ?? 'No link available',
                                      style: TextStyle(
                                        color: Color(0xFFF0F0F0),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _copyToClipboard,
                                    icon: Icon(
                                      Icons.copy,
                                      color: Color(0xFF1E90FF),
                                    ),
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
              ),
      ),
    );
  }
}
