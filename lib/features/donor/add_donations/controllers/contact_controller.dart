// lib/features/donor/add_donations/controllers/contact_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactController {
  final TextEditingController donorController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pickupController = TextEditingController();

  /// ✅ ADDED FOR MOBILE VALIDATION
  final FocusNode phoneFocusNode = FocusNode();
  bool phoneUnfocused = false;

  ContactController() {
    /// Listen for focus change
    phoneFocusNode.addListener(() {
      if (!phoneFocusNode.hasFocus) {
        phoneUnfocused = true;
      }
    });
  }

  /// Load saved contact details (autofill if available)
  Future<void> loadSavedContact() async {
  final prefs = await SharedPreferences.getInstance();

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final uid = user.uid;

  donorController.text =
      prefs.getString('donor_name_$uid') ??
      prefs.getString('donor_name') ??
      prefs.getString('donorName') ??
      '';

  phoneController.text =
      prefs.getString('donor_phone_$uid') ??
      prefs.getString('donor_phone') ??
      prefs.getString('donorPhone') ??
      '';

  pickupController.text =
      prefs.getString('donor_address_$uid') ??
      prefs.getString('donor_address') ??
      prefs.getString('pickupLocation') ??
      '';
}
  /// Save contact details
  Future<void> saveContact() async {
  final prefs = await SharedPreferences.getInstance();

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final uid = user.uid;

  final name = donorController.text.trim();
  final phone = phoneController.text.trim();
  final address = pickupController.text.trim();

  // Save per-user
  await prefs.setString('donor_name_$uid', name);
  await prefs.setString('donor_phone_$uid', phone);
  await prefs.setString('donor_address_$uid', address);
}

  /// Reset saved contact details
  Future<void> resetContact() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('donorName');
    await prefs.remove('donorPhone');
    await prefs.remove('pickupLocation');

    await prefs.remove('donor_name');
    await prefs.remove('donor_phone');
    await prefs.remove('donor_address');

    donorController.clear();
    phoneController.clear();
    pickupController.clear();

    phoneUnfocused = false; // reset validation state
  }

  void dispose() {
    donorController.dispose();
    phoneController.dispose();
    pickupController.dispose();
    phoneFocusNode.dispose(); // ✅ Dispose focus node
  }
}