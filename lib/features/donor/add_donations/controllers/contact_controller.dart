// lib/features/donor/add_donations/controllers/contact_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactController {
  final TextEditingController donorController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pickupController = TextEditingController();

  /// Load saved contact details (autofill if available)
  Future<void> loadSavedContact() async {
    final prefs = await SharedPreferences.getInstance();
    // Prefer the newer keys if present, fall back to old ones
    donorController.text =
        prefs.getString('donor_name') ?? prefs.getString('donorName') ?? '';
    phoneController.text =
        prefs.getString('donor_phone') ?? prefs.getString('donorPhone') ?? '';
    pickupController.text =
        prefs.getString('donor_address') ??
        prefs.getString('pickupLocation') ??
        '';
  }

  /// Save contact details (called on first submission or when updated)
  Future<void> saveContact() async {
    final prefs = await SharedPreferences.getInstance();
    final name = donorController.text.trim();
    final phone = phoneController.text.trim();
    final address = pickupController.text.trim();

    // Existing keys
    await prefs.setString('donorName', name);
    await prefs.setString('donorPhone', phone);
    await prefs.setString('pickupLocation', address);

    // Keys used by Profile/MyDonations (to keep their logic unchanged)
    await prefs.setString('donor_name', name);
    await prefs.setString('donor_phone', phone);
    await prefs.setString('donor_address', address);
  }

  /// Reset saved contact details (clear local storage and controllers)
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
  }

  void dispose() {
    donorController.dispose();
    phoneController.dispose();
    pickupController.dispose();
  }
}
