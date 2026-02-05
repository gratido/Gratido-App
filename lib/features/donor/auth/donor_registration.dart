// ignore_for_file: use_build_context_synchronously
import 'dart:ui';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../receiver/auth/firebase_auth_service.dart';
import '../donor_interface.dart';
import 'donor_loginpage.dart';
import 'package:gratido_sample/features/donor/location/donor_location_page.dart';

class DonorRegistration extends StatefulWidget {
  const DonorRegistration({super.key});

  @override
  State<DonorRegistration> createState() => _DonorRegistrationState();
}

class _DonorRegistrationState extends State<DonorRegistration> {
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
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
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

  // 🔥 ONE-TIME backend role registration (DONOR)
  Future<void> _registerDonorWithBackend(String token) async {
    const String backendUrl = 'https://192.168.0.1/api/auth/register';

    try {
      await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'role': 'donor',
        }),
      );
    } catch (_) {
      // ❗ Intentionally silent — Firebase signup must not break
    }
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
                final token = await user.getIdToken(true);

                if (token != null) {
                  await _registerDonorWithBackend(token);
                }

                if (!mounted) return;

                final enableLocation = await showAnimatedLocationPopup(context);

                if (!mounted) return;

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
                      builder: (_) => const DonorLoginPage(),
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
