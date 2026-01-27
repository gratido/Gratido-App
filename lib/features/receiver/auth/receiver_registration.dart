// ignore_for_file: use_build_context_synchronously
import 'dart:ui';

import 'package:flutter/material.dart';
import '../auth/firebase_auth_service.dart';
import 'package:gratido_sample/features/receiver/receiver_form.dart';
import 'receiver_loginpage.dart';

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

  bool _obscurePass = true;
  bool _obscureCpass = true;

  static const Color kPrimaryPurple = Color(0xFF6E5CD6);
  static const Color kDeepPurple = Color.fromARGB(255, 71, 53, 172);

  InputDecoration inputStyle(String label, {Widget? suffix}) {
    return InputDecoration(
      // 🔹 Floating label
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,

      // 🔹 Label styling (idle & floating)
      labelStyle: TextStyle(
        fontSize: 12,
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 12,
        color: kPrimaryPurple,
        fontWeight: FontWeight.w600,
      ),

      // 🔹 Glass field
      filled: true,
      fillColor: Colors.white.withOpacity(0.25),

      suffixIcon: suffix,

      // 🔹 Padding so label + text don’t collide
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),

      // 🔹 Border (pill shape like reference)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: Colors.white,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: Colors.white,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(
          color: kPrimaryPurple,
          width: 1.5,
        ),
      ),
    );
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        const Text(
          "Register",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 82, 63, 177)),
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
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: fname,
                decoration: inputStyle("First Name"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: lname,
                decoration: inputStyle("Last Name"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: email,
          decoration: inputStyle(
            "Email Address",
            suffix:
                const Icon(Icons.mail_outline, size: 20, color: kPrimaryPurple),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
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
        ),
        const SizedBox(height: 12),
        TextField(
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
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              backgroundColor: kPrimaryPurple,
              elevation: 8,
              shadowColor:
                  const Color.fromARGB(255, 126, 110, 216).withOpacity(0.25),
            ),
            onPressed: () async {
              if (pass.text.trim() != cpass.text.trim()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Passwords do not match")),
                );
                return;
              }

              final user = await _auth.signup(
                email.text.trim(),
                pass.text.trim(),
              );

              if (user != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReceiverFormPage(),
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
    );
  }
}
