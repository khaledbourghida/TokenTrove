import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class ExchangePage extends StatefulWidget {
  const ExchangePage({super.key});

  @override
  State<ExchangePage> createState() => _ExchangePageState();
}

class _ExchangePageState extends State<ExchangePage> {
  String statusFilter = 'pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromARGB(255, 48, 48, 48),
        title: const Text(
          "Exchange Requests",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          _buildStatusButton('pending'),
          _buildStatusButton('success'),
          _buildStatusButton('failed'),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('exchange')
            .where('status', isEqualTo: statusFilter)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No exchange requests found.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ExchangeCard(
                uid: data['uid'],
                email: data['email'],
                ffId: data['ff_id'],
                requiredToken: data['requiredToken'],
                diamond: data['diamond'],
                status: data['status'],
                docId: doc.id,
                onAccept: () => _handleAccept(doc.id, data),
                onReject: () => _handleReject(doc.id, data),
                isPending: statusFilter == 'pending',
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildStatusButton(String status) {
    return TextButton(
      onPressed: () => setState(() => statusFilter = status),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: statusFilter == status ? Colors.orange : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _handleAccept(String docId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('exchange').doc(docId).update(
        {'status': 'success'},
      );
      await sendEmail(data['email'], '✅ Exchange Accepted', '''
تم قبول طلب استبدالك بنجاح 🎉\n\n
لقد أرسلنا إليك ${data['diamond']} جوهرة إلى حسابك في فري فاير (ID: ${data['ff_id']})\n
📌 شكرًا لاستخدامك تطبيقنا.\n
---

Your exchange request has been approved 🎉\n\n
We have sent ${data['diamond']} diamonds to your Free Fire account (ID: ${data['ff_id']})\n
📌 Thank you for using our app.
''');
    } catch (e) {
      debugPrint("Error accepting exchange: $e");
    }
  }

  Future<void> _handleReject(String docId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('exchange')
          .doc(docId)
          .delete();
      await sendEmail(data['email'], '❌ Exchange Rejected', '''
نأسف، لقد تم رفض طلب الاستبدال الخاص بك.\n\n
الرجاء التأكد من صحة معلوماتك والمحاولة مجددًا لاحقًا.\n
---

Unfortunately, your exchange request was rejected.\n\n
Please verify your information and try again later.
''');
    } catch (e) {
      debugPrint("Error rejecting exchange: $e");
    }
  }

  Future<void> sendEmail(String recipient, String subject, String body) async {
    final smtpServer = gmail('prokhaled64@gmail.com', 'ictmcdnywyzjszdq');
    final message = Message()
      ..from = Address('prokhaled64@gmail.com', 'TokenTrove Admin')
      ..recipients.add(recipient)
      ..subject = subject
      ..text = body;

    try {
      await send(message, smtpServer);
    } catch (e) {
      debugPrint('Email send error: $e');
    }
  }
}

class ExchangeCard extends StatelessWidget {
  final String uid;
  final String email;
  final String ffId;
  final int requiredToken;
  final int diamond;
  final String status;
  final String docId;
  final bool isPending;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const ExchangeCard({
    super.key,
    required this.uid,
    required this.email,
    required this.ffId,
    required this.requiredToken,
    required this.diamond,
    required this.status,
    required this.docId,
    required this.onAccept,
    required this.onReject,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 48, 48, 48),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLine("Diamond", "$diamond"),
          _buildLine("Email", email),
          _buildLine("FF ID", ffId),
          _buildLine("Tokens", "$requiredToken"),
          _buildLine("Status", status),
          _buildLine("UID", uid),
          if (isPending)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Accept"),
                ),
                ElevatedButton(
                  onPressed: onReject,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Reject"),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLine(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        "$title : $value",
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
