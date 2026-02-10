// ignore_for_file: annotate_overrides, unnecessary_overrides, avoid_print

import 'dart:convert'; // ✅ Added for jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // ✅ Added for API calls
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Added for Token
import 'package:image_picker/image_picker.dart';

class FoodController with ChangeNotifier {
  // ---- API CONFIG ----
  // 🚨 IMPORTANT: Change this to your laptop's IP address (from ipconfig)
  static const String baseUrl = 'http://192.168.0.4/api';

  // ---- LOADING STATE ----
  bool isLoading = false; // ✅ Added to manage UI loading state

  // ---- FOOD NAME ----
  String? foodName;
  String? freshness;

  // ---- CATEGORY ----
  String? category;
  final List<String> categories = [
    'Cooked Meals',
    'Snacks',
    'Fruits',
    'Vegetables',
    'Baked Items',
    'Others',
    'Packed Food',
  ];

  // ---- QUANTITY ----
  int quantity = 0;

  // ---- PREPARED TIME ----
  final List<String> preparedOptions = [
    '1 hour ago',
    '1–3 hours ago',
    '3–6 hours ago',
    '6+ hours ago',
  ];
  String? preparedSelected;

  // ---- EXPIRY DATE ----
  String? expiryTime;
  DateTime? expiryDateObj;

  // ---- PICKUP WINDOW ----
  String? pickupWindow;
  String? pickupWindowOther;
  final List<String> pickupWindowOptions = [
    'ASAP',
    'Today 9am–12pm',
    'Today 1pm–4pm',
    'Tomorrow 9am–12pm',
    'Other',
  ];

  // ---- NOTES ----
  String? notes;

  // ---- HYGIENE ----
  bool hygieneConfirmed = false;

  // ---- IMAGES ----
  final ImagePicker picker = ImagePicker();
  final List<String> photoPaths = [];
  static const int maxPhotos = 5;

  // =====================================================
  // BACKEND SUBMISSION LOGIC
  // =====================================================

  // ✅ EXCITED FIX: THE COMPLETE 11-FIELD SYNC WITH PORT 5227!
  Future<bool> submitDonation(
      BuildContext context, String donorPhone, String addressText) async {
    if (!isValid) return false;
    isLoading = true;
    notifyListeners();

    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();

      // 🚨 PORT FIX: Ensuring 5227 is used for the physical phone connection
      final url = Uri.parse('http://192.168.0.4:5227/api/Donation/create');

      final Map<String, dynamic> donationData = {
        "foodTitle": foodName,
        "category": category,
        "quantity": quantity.toString(),
        "preparedTime": preparedSelected ?? "Not Specified", // ✨ FIXES DETAILS
        "donorPhone": donorPhone, // 📞 REAL MANUAL PHONE
        "pickupWindow": pickupWindow ?? "ASAP",
        "expiryDate":
            (expiryDateObj ?? DateTime.now().add(const Duration(days: 1)))
                .toIso8601String(), // 📅 Sending real ISO date
        "latitude": 12.9716, "longitude": 77.5946,
        "addressText": addressText, // 📍 REAL MANUAL ADDRESS
        "imageUrls": photoPaths,
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(donationData),
      );

      print("📡 SERVER RESPONSE: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ CONNECTION FAILED: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // =====================================================
  // SETTERS (Existing code preserved)
  // =====================================================

  void setFoodName(String v) {
    foodName = v.trim().isEmpty ? null : v.trim();
    notifyListeners();
  }

  void setCategory(String? c) {
    category = c;
    if (c == 'Packed Food') {
      preparedSelected = null;
      freshness = null;
    } else if (c == 'Fruits' || c == 'Vegetables') {
      preparedSelected = null;
    } else {
      freshness = null;
    }
    notifyListeners();
  }

  void setFreshness(String v) {
    freshness = v;
    notifyListeners();
  }

  void setQuantity(int q) {
    if (q < 0) q = 0;
    if (q > 100000) q = 100000;
    if (quantity != q) {
      quantity = q;
      notifyListeners();
    }
  }

  void setPrepared(String? val) {
    preparedSelected = val;
    notifyListeners();
  }

  void setExpiryDate(DateTime picked) {
    expiryDateObj = picked;
    expiryTime = "${picked.day}/${picked.month}/${picked.year}";
    notifyListeners();
  }

  void setPickupWindow(String? v) {
    pickupWindow = v;
    notifyListeners();
  }

  void setPickupOther(TimeOfDay t) {
    pickupWindowOther = formatTimeOfDay(t);
    notifyListeners();
  }

  String formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    final min = t.minute.toString().padLeft(2, '0');
    return "$hour:$min $suffix";
  }

  void setNotes(String? v) {
    notes = v;
    notifyListeners();
  }

  void setHygiene(bool v) {
    hygieneConfirmed = v;
    notifyListeners();
  }

  // =====================================================
  // IMAGES
  // =====================================================

  Future<bool> pickImage() async {
    if (photoPaths.length >= maxPhotos) return false;
    final XFile? img = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 78,
    );
    if (img != null) {
      photoPaths.add(img.path);
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeImage(int index) {
    if (index >= 0 && index < photoPaths.length) {
      photoPaths.removeAt(index);
      notifyListeners();
    }
  }

  // =====================================================
  // VALIDATION
  // =====================================================

  bool get isValid {
    final pickupValid = pickupWindow != null &&
        (pickupWindow != 'Other' ||
            (pickupWindowOther != null && pickupWindowOther!.isNotEmpty));

    final bool timeRequirementValid = (category == 'Packed Food') ||
        (category == 'Fruits' || category == 'Vegetables'
            ? freshness != null
            : preparedSelected != null);

    return foodName != null &&
        foodName!.isNotEmpty &&
        category != null &&
        timeRequirementValid &&
        expiryTime != null &&
        pickupValid &&
        quantity > 0 &&
        photoPaths.isNotEmpty &&
        hygieneConfirmed;
  }

  // =====================================================
  // RESET
  // =====================================================

  void reset() {
    foodName = null;
    freshness = null;
    category = null;
    quantity = 0;
    preparedSelected = null;
    expiryTime = null;
    expiryDateObj = null;
    pickupWindow = null;
    pickupWindowOther = null;
    notes = null;
    hygieneConfirmed = false;
    photoPaths.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
