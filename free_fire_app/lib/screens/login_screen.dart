import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:free_fire_app/screens/resetPassword_screen.dart';
import 'package:free_fire_app/screens/verifyEmail_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

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

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim());
      final docSnap = await userDoc.get();
      final data = docSnap.docs.first;
      if (data['isVerify']) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        String message = "The email address is not verified";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Color(0xFFFF4500)),
        );
        showEmailVerificationDialog(
          context: context,
          email: _emailController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user has been disabled.';
          break;
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        default:
          message = 'Login failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Color(0xFFFF4500)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
          backgroundColor: Color(0xFFFF4500),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF4500), Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF4500).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'TT',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF0F0F0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
                SizedBox(height: 40),
                // Email Field
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
                // Password Field
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
                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_emailController.text.trim().isEmpty ||
                                _passwordController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please enter email and password',
                                  ),
                                  backgroundColor: Color(0xFFFF4500),
                                ),
                              );
                              return;
                            }
                            if (_passwordController.text.trim().length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Password must be at least 6 characters',
                                  ),
                                  backgroundColor: Color(0xFFFF4500),
                                ),
                              );
                              return;
                            }
                            await _signIn();
                          },
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
                            'Sign In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                // Sign Up Button
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                  child: Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(color: Color(0xFF1E90FF), fontSize: 16),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResetpasswordScreen(),
                            ),
                          );
                        },
                  child: Text(
                    'Forget password ?',
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
    super.dispose();
  }
}
