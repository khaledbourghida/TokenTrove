import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class VerifyemailScreen extends StatefulWidget {
  final String email;

  const VerifyemailScreen({super.key, required this.email});

  @override
  _VerifyemailScreenState createState() => _VerifyemailScreenState();
}

class _VerifyemailScreenState extends State<VerifyemailScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool _loading = false;
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Future<String?> sendAndStoreVerificationCode(
    String uid,
    String recipientEmail,
  ) async {
    setState(() {
      _loading = true;
    });

    final String verificationCode = (Random().nextInt(900000) + 100000)
        .toString();

    final smtpServer = gmail(
      'prokhaled64@gmail.com',
      'ictmcdnywyzjszdq', // ⚠️ Use Gmail App Password
    );

    final message = Message()
      ..from = Address('prokhaled64@gmail.com', 'TokenTrove Admin')
      ..recipients.add(recipientEmail)
      ..subject = 'Your Email Verification Code'
      ..html =
          """
        <h2>🔑 Verify Your Email</h2>
        <p>Use the following code to verify your email:</p>
        <h1 style="color:#27AE60;">$verificationCode</h1>
        <p>This code expires in 10 minutes.</p>
      """;

    try {
      await send(message, smtpServer);

      final expiry = DateTime.now().add(Duration(minutes: 10));
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "verificationCode": verificationCode,
        "codeExpiry": expiry,
      }, SetOptions(merge: true));

      setState(() {
        _loading = false;
      });

      print("✅ Code sent & stored for $recipientEmail");
      return verificationCode;
    } catch (e) {
      print("❌ Failed: $e");
      setState(() {
        _loading = false;
      });
      return null;
    }
  }

  Future<bool> verifyUserCode(String uid, String enteredCode) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) return false;

    final data = doc.data()!;
    final storedCode = data["verificationCode"];
    final expiry = (data["codeExpiry"] as Timestamp).toDate();

    if (DateTime.now().isAfter(expiry)) {
      print("❌ Code expired");
      return false;
    }

    if (storedCode == enteredCode) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        "isVerify": true,
      });
      print("✅ Email verified!");
      return true;
    } else {
      print("❌ Invalid code");
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    sendAndStoreVerificationCode(user!.uid, widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Enter the 6-digit code sent to your email",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: "",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            }
                            if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      final enteredCode = _controllers
                          .map((c) => c.text)
                          .join();
                      if (enteredCode.length == 6) {
                        bool success = await verifyUserCode(
                          user!.uid,
                          enteredCode,
                        );
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✅ Email Verified Successfully"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("❌ Invalid or Expired Code"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text("Verify"),
                  ),
                  TextButton(
                    onPressed: () {
                      sendAndStoreVerificationCode(user!.uid, widget.email);
                    },
                    child: const Text("Resend Code"),
                  ),
                ],
              ),
            ),
    );
  }
}
