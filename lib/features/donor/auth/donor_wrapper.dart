// lib/features/donor/auth/donor_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../donor_interface.dart';
import 'donor_loginpage.dart';

class DonorWrapper extends StatelessWidget {
  const DonorWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // DEBUG
        debugPrint('DonorWrapper: snapshot.hasData=${snapshot.hasData}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔒 Not logged in → Login page
        if (!snapshot.hasData) {
          debugPrint('DonorWrapper -> sending to DonorLoginPage');
          return const DonorLoginPage();
        }

        // ✅ Logged in → Donor Home Interface
        debugPrint('DonorWrapper -> sending to DonorInterface');
        return const DonorInterface();
      },
    );
  }
}
