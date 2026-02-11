// lib/features/receiver/auth/wrapperclass.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../receiver_form.dart';
import '../receiver_home.dart';
import 'receiver_loginpage.dart';

class WrapperClass extends StatelessWidget {
  const WrapperClass({super.key});

  /// 🕵️‍♂️ SENIOR LOGIC: Calls the Backend to see if an NGO profile exists
  // 🕵️‍♂️ Optimized Check: Only calls API once per login session
  Future<Map<String, dynamic>?> _checkProfile(User user) async {
    try {
      final token = await user.getIdToken();

      // ✅ SENIOR FIX: Added 5-second timeout so it doesn't buffer forever
      final response = await http.get(
        Uri.parse('http://192.168.0.4:5227/api/Receiver/my-profile'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint(
          "⚠️ Connection Timeout/Error: Ensure Backend is running at 192.168.0.4");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 1. Check if Firebase is still loading
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. If NOT logged into Firebase, go to Login Page
        if (!authSnapshot.hasData) {
          debugPrint('Wrapper -> User not logged in. Sending to Login.');
          return const ReceiverLoginPage();
        }

        // 3. User is logged into Firebase. Now check the Backend Database.
        final User user = authSnapshot.data!;

        return FutureBuilder<Map<String, dynamic>?>(
          future: _checkProfile(user),
          builder: (context, profileSnapshot) {
            // Show loading while checking the DB
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple)),
              );
            }

            final profile = profileSnapshot.data;

            if (profile != null) {
              debugPrint(
                  '🕵️‍♂️ Wrapper: Keys from Backend are: ${profile.keys.toList()}');

              // 🛡️ STRICT MATCHING: Matches the camelCase keys from your logs
              final String finalAddress = profile['address'] ??
                  profile['Address'] ??
                  "Address missing in JSON";

              final bool isVerified = profile['isVerified'] ?? false;

              final double latitude =
                  (profile['latitude'] ?? profile['Latitude'] ?? 0.0)
                      .toDouble();
              final double longitude =
                  (profile['longitude'] ?? profile['Longitude'] ?? 0.0)
                      .toDouble();

              return ReceiverHomePage(
                isVerified: isVerified,
                address: finalAddress,
                lat: latitude,
                lng: longitude,
              );
            } else {
              // ❌ No profile found in DB -> MUST show the Form
              debugPrint('⚠️ No profile found. User must fill the form.');
              return const ReceiverFormPage();
            }
          },
        );
      },
    );
  }
}
