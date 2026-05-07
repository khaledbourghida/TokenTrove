import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppStatusPage extends StatefulWidget {
  const AppStatusPage({Key? key}) : super(key: key);

  @override
  State<AppStatusPage> createState() => _AppStatusPageState();
}

class _AppStatusPageState extends State<AppStatusPage> {
  bool _loading = true;
  String issueMessage = "";

  @override
  void initState() {
    super.initState();
    _checkAppStatus();
  }

  Future<void> _checkAppStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('status')
          .get();

      final data = doc.data()!;
      issueMessage = data['issueMessage'] ?? "An issue has occurred.";
    } catch (e) {
      issueMessage = "Error checking app status.";
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoading();
    }
    return _buildStatusCard(
      icon: Icons.warning_amber_rounded,
      title: "App Issue",
      message: issueMessage,
      buttonText: "Retry Later",
      onPressed: () => {},
      color: Colors.red,
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.orange)),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(24),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 60),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onPressed,
                child: Text(buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
