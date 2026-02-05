// ignore_for_file: use_build_context_synchronously
import 'dart:ui';

import 'package:flutter/material.dart';
import '../../receiver/auth/firebase_auth_service.dart';
import 'donor_registration.dart';
import 'donor_forgotpassword.dart';
import '../donor_interface.dart';
import 'package:gratido_sample/features/donor/location/donor_location_page.dart'; // ✅ ADDED (ONLY IMPORT)

class DonorLoginPage extends StatefulWidget {
  const DonorLoginPage({super.key});

  @override
  State<DonorLoginPage> createState() => _DonorLoginPageState();
}

class _DonorLoginPageState extends State<DonorLoginPage> {
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
      labelText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(
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
          '"Ready to make a difference today?"',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 55, 32, 90),
          ),
        ),
        const SizedBox(height: 28),

        TextField(
          controller: emailController,
          decoration: inputStyle(
            hint: "Email address",
            prefix:
                const Icon(Icons.mail_outline, color: kPrimaryPurple, size: 20),
          ),
        ),
        const SizedBox(height: 16),

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
                  builder: (_) => const DonorForgotPasswordPage(),
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

        /// 🔐 EMAIL LOGIN — FIXED (LOGIC ONLY)
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E5CD6),
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
                final enableLocation =
                    await showAnimatedLocationPopup(context); // ✅ RESULT USED

                if (enableLocation == true) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DonorLocationPage(),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DonorInterface(),
                    ),
                  );
                }
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

        /// 🔐 GOOGLE LOGIN — FIXED (LOGIC ONLY)
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
                final enableLocation =
                    await showAnimatedLocationPopup(context); // ✅ RESULT USED

                if (enableLocation == true) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DonorLocationPage(),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DonorInterface(),
                    ),
                  );
                }
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
                    builder: (_) => const DonorRegistration(),
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

/// =======================================================
/// 🔔 ENABLE LOCATION POPUP (PASTED AS-IS, NO UI CHANGES)
/// =======================================================
Future<Object?> showAnimatedLocationPopup(BuildContext context) async {
  const Color primaryPurple = Color(0xFF7C3AED);
  const Color secondaryGrey = Color(0xFF6B7280);
  final double dialogWidth = MediaQuery.of(context).size.width * 0.82;
  return await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) => const SizedBox(),
    transitionBuilder: (context, anim, __, ___) {
      return Transform.scale(
        scale: 0.96 + (anim.value * 0.04),
        child: Opacity(
          opacity: anim.value,
          child: Center(
            child: Container(
              width: dialogWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.22),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// ICON WITH WIDER, SOFTER GLOW
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryPurple
                                        .withOpacity(0.34), // ⬅️ +5%
                                    blurRadius: 70, // ⬅️ wider fade
                                    spreadRadius: 20, // ⬅️ reaches sides
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryPurple.withOpacity(0.14),
                              ),
                            ),
                            Icon(
                              Icons.location_on,
                              size: 30,
                              color: primaryPurple,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Enable Location',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Allow location so nearby receivers\n'
                        'can find your donation.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              height: 1.35,
                              color: secondaryGrey,
                            ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPurple,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            'Enable Location',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Maybe Later',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: secondaryGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
