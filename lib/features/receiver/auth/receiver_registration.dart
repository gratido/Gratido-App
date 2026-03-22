// ignore_for_file: use_build_context_synchronously
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../auth/firebase_auth_service.dart';
import 'receiver_loginpage.dart';
import '../auth/wrapperclass.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiverRegistration extends StatefulWidget {
  const ReceiverRegistration({super.key});

  @override
  State<ReceiverRegistration> createState() => _ReceiverRegistrationState();
}

class _ReceiverRegistrationState extends State<ReceiverRegistration> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController fname = TextEditingController();
  final TextEditingController lname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final TextEditingController cpass = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePass = true;
  bool _obscureCpass = true;

  static const Color kPrimaryPurple = Color(0xFF6E5CD6);

  InputDecoration inputStyle(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(
        fontSize: 12,
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 12,
        color: kPrimaryPurple,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.25),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Colors.white, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: Colors.white, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: kPrimaryPurple, width: 1.5),
      ),
    );
  }

  Future<void> _registerReceiverWithBackend(String token) async {
    const String backendUrl = 'http://192.168.0.5:5227/api/auth/register';

    try {
      await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'role': 'Receiver',
        }),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F3FF),
              Color(0xFFE9D5FF),
              Color(0xFFDDD6FE),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildGlassCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(40, 124, 58, 237),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: _buildFormContent(context),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          const Text(
            "Register",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 82, 63, 177),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Join our community today, to make a difference',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(137, 85, 50, 149),
            ),
          ),
          const SizedBox(height: 24),

          /// FIRST + LAST NAME
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: fname,
                  decoration: inputStyle("First Name"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "First name is required";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: lname,
                  decoration: inputStyle("Last Name"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Last name is required";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// EMAIL
          TextFormField(
            controller: email,
            decoration: inputStyle(
              "Email Address",
              suffix: const Icon(
                Icons.mail_outline,
                size: 20,
                color: kPrimaryPurple,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Email is required";
              }

              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

              if (!emailRegex.hasMatch(value.trim())) {
                return "Enter valid email";
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          /// PASSWORD
          TextFormField(
            controller: pass,
            obscureText: _obscurePass,
            decoration: inputStyle(
              "Password",
              suffix: IconButton(
                icon: Icon(
                  _obscurePass ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: kPrimaryPurple,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePass = !_obscurePass;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password is required";
              }
              if (value.length < 8) {
                return "Minimum 8 characters required";
              }
              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return "Must contain 1 uppercase letter";
              }
              if (!RegExp(r'[a-z]').hasMatch(value)) {
                return "Must contain 1 lowercase letter";
              }
              if (!RegExp(r'[0-9]').hasMatch(value)) {
                return "Must contain 1 number";
              }
              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                return "Must contain 1 special character";
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          /// CONFIRM PASSWORD
          TextFormField(
            controller: cpass,
            obscureText: _obscureCpass,
            decoration: inputStyle(
              "Confirm Password",
              suffix: IconButton(
                icon: Icon(
                  _obscureCpass ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: kPrimaryPurple,
                ),
                onPressed: () {
                  setState(() {
                    _obscureCpass = !_obscureCpass;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please confirm password";
              }
              if (value != pass.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),

          const SizedBox(height: 22),

          /// BUTTON (LOGIC UNCHANGED)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: kPrimaryPurple,
              ),
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                final user = await _auth.signup(
  email.text.trim(),
  pass.text.trim(),
  "Receiver",
  "${fname.text.trim()} ${lname.text.trim()}",
);
                print("Returned user: $user");

                if (user != null) {
                  final token = await user.getIdToken(true);

                  if (token != null) {
                    await _registerReceiverWithBackend(token);
                  }

                  // ✅ SAVE RECEIVER DATA FOR PROFILE PAGE
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('receiver_name', fname.text.trim());
                  await prefs.setString('receiver_email', email.text.trim());
                  await prefs.setString('receiver_phone', '');
                  await prefs.setString('receiver_address', '');

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WrapperClass(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Signup failed")),
                  );
                }
              },
              child: const Text(
                "Create Account",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          /// SIGN IN
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Already have an account?",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReceiverLoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Sign in",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 99, 76, 213),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
