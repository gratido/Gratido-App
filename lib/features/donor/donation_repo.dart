// lib/features/donor/donation_repo.dart
import 'package:flutter/foundation.dart';

class Donation {
  final String id;
  final String donorName;
  final String? foodName; // NEW optional food name
  final String phone;
  final String pickupLocation;
  final String pickupWindow;
  final String? pickupWindowOther;
  final String category;
  final int quantity;
  final List<String> photoPaths;
  final bool hygieneConfirmed;
  final String? preparedTime;
  final String? expiryTime;
  final String? notes;
  final DateTime createdAt;
  bool isNew;

  Donation({
    String? id,
    required this.donorName,
    this.foodName, // accept optional foodName
    required this.phone,
    required this.pickupLocation,
    required this.pickupWindow,
    this.pickupWindowOther,
    required this.category,
    required this.quantity,
    List<String>? photoPaths,
    required this.hygieneConfirmed,
    this.preparedTime,
    this.expiryTime,
    this.notes,
    DateTime? createdAt,
    this.isNew = true,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       photoPaths = photoPaths ?? <String>[],
       createdAt = createdAt ?? DateTime.now();
}

class DonationRepo extends ChangeNotifier {
  DonationRepo._internal();
  static final DonationRepo instance = DonationRepo._internal();

  final List<Donation> _items = [];
  List<Donation> get items => List.unmodifiable(_items);

  void addDonation(Donation d) {
    _items.insert(0, d);
    notifyListeners();
  }

  void removeDonation(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void markSeen(String id) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _items[idx].isNew = false;
      notifyListeners();
    }
  }

  void seedDemo() {
    if (_items.isNotEmpty) return;
    addDonation(
      Donation(
        donorName: 'Featured Listing',
        foodName: 'Donation Drive at Central Park', // sample
        phone: '+91 9876543210',
        pickupLocation: 'Central Park',
        pickupWindow: '30 mins',
        category: 'Cooked Meals',
        quantity: 20,
        photoPaths: ['assets/images/sample1.jpg'],
        hygieneConfirmed: true,
        preparedTime: '1 hour ago',
        expiryTime: 'Today',
        notes: 'Fresh meals',
        isNew: false,
      ),
    );
  }
}
