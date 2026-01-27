// ignore_for_file: use_build_context_synchronously
import 'dart:ui';

import 'package:flutter/material.dart';
import '../auth/firebase_auth_service.dart';
import 'receiver_registration.dart';
import 'forgotpassword_interface.dart';
import '../receiver_home.dart';

class ReceiverLoginPage extends StatefulWidget {
  const ReceiverLoginPage({super.key});

  @override
  State<ReceiverLoginPage> createState() => _ReceiverLoginPageState();
}

class _ReceiverLoginPageState extends State<ReceiverLoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  static const Color kPrimaryPurple = Color(0xFF6E5CD6);
  static const Color kDeepPurple = Color.fromARGB(255, 71, 53, 172);

  InputDecoration inputStyle({
    required String hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      // 🔹 Floating label instead of placeholder
      labelText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.auto,

      // 🔹 Label styling
      labelStyle: TextStyle(
        color: Colors.black54,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: kPrimaryPurple,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),

      prefixIcon: prefix,
      suffixIcon: suffix,

      filled: true,
      fillColor: Colors.white.withOpacity(0.55),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),

      // 🔹 Borders unchanged
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: kPrimaryPurple.withOpacity(0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: kPrimaryPurple.withOpacity(0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: kPrimaryPurple,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: [
              Color(0xFFF5F3FF),
              Color(0xFFEDE9FE),
              Color(0xFFDDD6FE),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _glassCard(context),
          ),
        ),
      ),
    );
  }

  Widget _glassCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(40, 124, 58, 237),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(48),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: _content(context),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 6),
        const Text(
          "Welcome back!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 93, 73, 193),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '"Ready to spread more kindness?"',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 55, 32, 90),
          ),
        ),
        const SizedBox(height: 28),

        // Email
        TextField(
          controller: emailController,
          decoration: inputStyle(
            hint: "Email address",
            prefix:
                const Icon(Icons.mail_outline, color: kPrimaryPurple, size: 20),
          ),
        ),
        const SizedBox(height: 16),

        // Password
        TextField(
          controller: passwordController,
          obscureText: _obscurePassword,
          decoration: inputStyle(
            hint: "Password",
            prefix:
                const Icon(Icons.lock_outline, color: kPrimaryPurple, size: 20),
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: kPrimaryPurple.withOpacity(0.7),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ForgotPasswordPage(),
                ),
              );
            },
            child: const Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kPrimaryPurple,
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // Sign in button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6E5CD6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              shadowColor: kPrimaryPurple.withOpacity(0.20),
            ),
            onPressed: () async {
              final user = await _auth.login(
                emailController.text.trim(),
                passwordController.text.trim(),
              );
              if (user != null) {
                Navigator.pushReplacementNamed(context, '/receiver');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Login failed")),
                );
              }
            },
            child: const Text(
              "Sign In",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 26),

        // OR divider
        Row(
          children: [
            Expanded(child: Divider(color: kPrimaryPurple.withOpacity(0.25))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "OR",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
            Expanded(child: Divider(color: kPrimaryPurple.withOpacity(0.25))),
          ],
        ),

        const SizedBox(height: 18),

        // Google button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.4),
              side: BorderSide(color: Colors.white.withOpacity(0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () async {
              final user = await _auth.googleLogin();
              if (user != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReceiverHomePage(),
                  ),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/google.png',
                  height: 45,
                  width: 45,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.error, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Continue with Google",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kDeepPurple,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 26),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "New here?",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReceiverRegistration(),
                  ),
                );
              },
              child: const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 12,
                  color: kPrimaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
