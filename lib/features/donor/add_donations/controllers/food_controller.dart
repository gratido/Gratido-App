// lib/features/donor/add_donations/controllers/food_controller.dart
// ignore_for_file: annotate_overrides, unnecessary_overrides
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FoodController with ChangeNotifier {
  // ---- FOOD NAME ----
  String? foodName;

  // ---- CATEGORY ----
  String? category;
  final List<String> categories = [
    'Cooked Meals',
    'Snacks',
    'Fruits',
    'Vegetables',
    'Baked Items',
    'Other Cooked Meals',
  ];

  // ---- QUANTITY ----
  int quantity = 10;

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
  // SETTERS
  // =====================================================
  void setFoodName(String v) {
    foodName = v.trim();
    notifyListeners();
  }

  void setCategory(String? c) {
    category = c;
    notifyListeners();
  }

  void incrementQuantity() {
    quantity++;
    notifyListeners();
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
      notifyListeners();
    }
  }

  void setQuantity(int q) {
    if (q < 1) q = 1;
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

  // =====================================================
  // IMAGES (MAX 5)
  // =====================================================
  Future<bool> pickImage() async {
    if (photoPaths.length >= maxPhotos) {
      notifyListeners(); // UI can detect limit reached
      return false;
    }
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

  void setHygiene(bool v) {
    hygieneConfirmed = v;
    notifyListeners();
  }

  // =====================================================
  // VALIDATION
  // =====================================================
  bool get isValid {
    final pickupValid =
        pickupWindow != null &&
        (pickupWindow != 'Other' ||
            (pickupWindowOther != null && pickupWindowOther!.isNotEmpty));
    return foodName != null &&
        foodName!.isNotEmpty &&
        category != null &&
        preparedSelected != null && // required now
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
    category = null;
    quantity = 10;
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

  void dispose() {
    super.dispose();
  }
}
