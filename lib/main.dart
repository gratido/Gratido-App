// lib/main.dart
// Full file — uses onGenerateRoute to safely handle DonationDetail with runtime args.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gratido_sample/features/receiver/auth/receiver_registration.dart';

import 'features/donor/add_donations/add_donations.dart';
import 'features/donor/mydonations.dart';
import 'features/donor/donor_listing.dart';
import 'features/donor/donation_detail.dart';
import 'features/donor/donor_interface.dart';
import 'features/donor/donation_repo.dart';
import 'features/onboarding_cards/onboarding_screen.dart';
import 'package:gratido_sample/features/receiver/auth/wrapperclass.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://iryipjtijhtalkcoddqv.supabase.co', // 👈 PASTE YOUR URL HERE
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlyeWlwanRpamh0YWxrY29kZHF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4MTA0MDAsImV4cCI6MjA4NTM4NjQwMH0.2_Yjn-aSwltyU1kzFHRe1Ijqr_5OD8d4WSDK_4dj69c', // 👈 PASTE YOUR KEY HERE
  );

  runApp(const GratidoApp());
}

class GratidoApp extends StatelessWidget {
  const GratidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GratidoApp',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),

      // onGenerateRoute handles routes that require runtime arguments (DonationDetail)
      onGenerateRoute: (RouteSettings settings) {
        // Route for donation detail — expects a Donation instance as arguments
        if (settings.name == '/donation_detail') {
          final args = settings.arguments;

          if (args is Donation) {
            return MaterialPageRoute<void>(
              builder: (context) => DonationDetail(donation: args),
              settings: settings,
            );
          }

          // fallback when wrong args were supplied
          return MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Donation details')),
              body: const Center(child: Text('No donation data provided.')),
            ),
            settings: settings,
          );
        }

        // Let other named routes be handled by the routes table below:
        return null;
      },

      // Named routes for pages that don't need runtime args
      routes: {
        '/add_donation': (_) => const AddDonationsScreen(),
        '/my_donations': (_) => const MyDonations(),
        '/donor_listing': (_) => DonorListing(),
        '/donor_interface': (_) => DonorInterface(),

        // Receiver wrapper route (uses wrapper to decide Login / Documents / Home)
        '/receiver': (_) => const WrapperClass(),

        // Receiver registration if needed
        '/receiver_registration': (_) => const ReceiverRegistration(),
      },

      // --------------------------
      home: const OnboardingScreen(),
      // Keep the original home screen
    );
  }
}
