// lib/features/donor/donation_repo.dart
import 'package:flutter/foundation.dart';

class Donation {
  final String id;
  final String donorName;
  final String? foodName;
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
    this.foodName,
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
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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

  void expireNewFlags() {
    final now = DateTime.now();
    bool changed = false;

    for (final d in _items) {
      if (d.isNew && now.difference(d.createdAt).inHours >= 4) {
        d.isNew = false;
        changed = true;
      }
    }

    if (changed) notifyListeners();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }

  void seedDemo() {
    if (_items.isNotEmpty) return;

    // 1️⃣ Donation Drive at Central Park
    addDonation(
      Donation(
        donorName: 'Featured Listing',
        foodName: 'Donation Drive at Central Park',
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

    // 2️⃣ Community Kitchen
    addDonation(
      Donation(
        donorName: 'Community Kitchen',
        foodName: 'Rice & Curry',
        phone: '+91 9123456789',
        pickupLocation: 'Greenwood Street',
        pickupWindow: 'Today 9am - 12pm',
        category: 'Vegetables',
        quantity: 35,
        photoPaths: ['assets/images/sample2.png'],
        hygieneConfirmed: true,
        preparedTime: '6hrs ago',
        expiryTime: 'Tomorrow',
        notes: 'Fresh vegetables',
        isNew: false,
      ),
    );

    // 3️⃣ Bakery Surplus
    addDonation(
      Donation(
        donorName: 'Ramesh Kumar',
        foodName: 'Bakery Surplus',
        phone: '+91 9988776655',
        pickupLocation: 'Baker Street',
        pickupWindow: 'tomorrow 12 - 3pm',
        category: 'Breads',
        quantity: 15,
        photoPaths: ['assets/images/sample3.jpg'],
        hygieneConfirmed: true,
        preparedTime: 'Afternoon',
        expiryTime: 'Tonight',
        notes: 'Unsold bakery items',
        isNew: false,
      ),
    );
  }
}
