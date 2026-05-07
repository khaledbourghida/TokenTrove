import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:free_fire_app/screens/verifyEmail_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ffIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty ||
          _nameController.text.trim().isEmpty ||
          _ffIdController.text.trim().isEmpty) {
        throw Exception('Please fill in all fields.');
      }
      if (_passwordController.text.trim().length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      // Store extra info in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': _nameController.text.trim(),
            'ff_id': _ffIdController.text.trim(),
            'email': _emailController.text.trim(),
            'tokenCount': 0,
            'totalTokenCount': 0,
            'role': 'user',
            'settings': {'language': "en", 'mode': "dark"},
            'invited': [],
            'created_at': Timestamp.now(),
            'lastActive': Timestamp.now(),
            'status': 'connected',
            'isVerify': false,
          });
      final snapshot = await FirebaseFirestore.instance
          .collection('competitions')
          .where('isActive', isEqualTo: true)
          .get();
      if (!snapshot.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'comp': 0});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sign up successful! Please verify your email before logging in.',
          ),
          backgroundColor: Color(0xFFFF4500),
        ),
      );
      // Navigator.pushReplacementNamed(context, '/login');
      showEmailVerificationDialog(
        context: context,
        email: _emailController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already in use.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Operation not allowed. Please contact support.';
          break;
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        default:
          message = 'Sign up failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Color(0xFFFF4500)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Color(0xFFFF4500),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> showEmailVerificationDialog({
    required BuildContext context,
    required String email,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false, // force user to choose
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: const [
            Icon(Icons.verified_user_outlined, color: Colors.orange, size: 22),
            SizedBox(width: 8),
            Text(
              'Email Verification',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "We sent a verification code to:",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Do you want to verify your email now or later?",
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.close, color: Colors.red),
            label: const Text(
              "Later",
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            label: const Text(
              "Verify Now",
              style: TextStyle(color: Colors.green, fontSize: 14),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VerifyemailScreen(email: email),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: Color(0xFFF0F0F0)),
                  decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle: TextStyle(
                      color: Color(0xFFF0F0F0).withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF1E90FF)),
                  ),
                ),
                SizedBox(height: 20),
                // FF ID
                TextField(
                  controller: _ffIdController,
                  style: TextStyle(color: Color(0xFFF0F0F0)),
                  decoration: InputDecoration(
                    hintText: 'Free Fire ID',
                    hintStyle: TextStyle(
                      color: Color(0xFFF0F0F0).withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.videogame_asset,
                      color: Color(0xFF1E90FF),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Email
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: Color(0xFFF0F0F0)),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(
                      color: Color(0xFFF0F0F0).withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.email, color: Color(0xFF1E90FF)),
                  ),
                ),
                SizedBox(height: 20),
                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: Color(0xFFF0F0F0)),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      color: Color(0xFFF0F0F0).withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF1E90FF)),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFF4500),
                      foregroundColor: Color(0xFFF0F0F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 10,
                      shadowColor: Color(0xFFFF4500).withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Color(0xFFF0F0F0))
                        : Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Color(0xFF1E90FF), fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _ffIdController.dispose();
    super.dispose();
  }
}
