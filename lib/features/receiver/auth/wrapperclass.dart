// lib/features/receiver/auth/wrapperclass.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config.dart'; // adjust path if needed
import '../receiver_form.dart'; // adjust path if needed
import '../receiver_home.dart'; // adjust path if needed
import 'receiver_loginpage.dart';

class WrapperClass extends StatelessWidget {
  const WrapperClass({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // DEBUG
        debugPrint('WrapperClass: snapshot.hasData=${snapshot.hasData}');
        debugPrint(
          'WrapperClass: AppConfig.skipReceiverDocumentFlow=${AppConfig.skipReceiverDocumentFlow}',
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          debugPrint('WrapperClass -> sending to LoginPage');
          return const ReceiverLoginPage();
        }

        // User is logged in
        if (AppConfig.skipReceiverDocumentFlow) {
          debugPrint(
            'WrapperClass -> SKIP documents: sending to ReceiverHomePage',
          );
          return const ReceiverHomePage();
        } else {
          debugPrint(
            'WrapperClass -> NORMAL flow: sending to ReceiverFormPage',
          );
          return const ReceiverFormPage();
        }
      },
    );
  }
}