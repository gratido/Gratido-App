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
  final String quantity; // ✅ Standardized as String to kill the red error
  final List<String> photoPaths;
  final bool hygieneConfirmed;
  final String? preparedTime;
  final String? expiryTime;
  final String? notes;
  final DateTime createdAt;
  final String status;
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
    this.status = "Pending",
    this.isNew = true,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        photoPaths = photoPaths ?? <String>[],
        createdAt = createdAt ?? DateTime.now();

  // ✅ SYNCED & BULLETPROOF: Maps all 11 backend columns to Flutter
  // ✅ EXCITED UPDATE: NO MORE "N/A"! THIS MAPS ALL 11 REAL DATABASE FIELDS!
  factory Donation.fromJson(Map<String, dynamic> json) {
    final createdDate = DateTime.tryParse(json['createdAt'] ?? "")?.toUtc() ??
        DateTime.now().toUtc();
    String displayExpiry = json['expiryDateText'] ?? "Not specified";
    String rawUrls = json['imageUrls']?.toString() ?? "";
    List<String> carouselPaths = rawUrls.isNotEmpty ? rawUrls.split(',') : [];

    if (json['expiryDate'] != null) {
      try {
        final expiryDate = DateTime.parse(json['expiryDate']);
        final now = DateTime.now();
        final difference = expiryDate.difference(now);

        if (difference.inDays > 1) {
          displayExpiry = "In ${difference.inDays} days";
        } else if (difference.inHours > 1) {
          displayExpiry = "In ${difference.inHours} hours";
        } else if (difference.inMinutes > 1) {
          displayExpiry = "In ${difference.inMinutes} mins";
        } else {
          displayExpiry = "Expiring soon";
        }
      } catch (e) {
        // If parsing fails, keep the original text or default
      }
    }
    return Donation(
      id: json['id']?.toString() ?? "",
      donorName: "My Listing",
      foodName: json['foodTitle']?.toString() ?? "Untitled Food",
      phone: json['donorPhone']?.toString() ?? "No Phone", // 📱 REAL PHONE!
      pickupLocation:
          json['address']?.toString() ?? "No address", // 📍 REAL ADDRESS!
      pickupWindow: json['pickupWindow']?.toString() ?? "ASAP",
      category: json['category']?.toString() ?? "Food",
      quantity: json['quantity']?.toString() ?? "0", // 🔟 QUANTITY 10 FIX!
      photoPaths: carouselPaths,
      hygieneConfirmed: true,
      preparedTime:
          json['preparedTime']?.toString() ?? "Just now", // ⏱️ PREPARED TIME!
      expiryTime:
          displayExpiry, // ✅ DYNAMIC DATE (June 6 or whatever you pick!) // 📅 EXPIRY JUNE 6 FIX!
      notes: json['address']?.toString(),
      status: json['status']?.toString() ?? "Pending",
      createdAt: createdDate,
      isNew: DateTime.now().difference(createdDate).inHours < 2,
    );
  }
}

class DonationRepo extends ChangeNotifier {
  DonationRepo._internal();
  static final DonationRepo instance = DonationRepo._internal();

  final List<Donation> _items = [];
  List<Donation> get items => List.unmodifiable(_items);

  // ✅ EXCITED FIX: THIS PROTECTS SEEDS AND PREVENTS DUPLICATES!
  void setServerItems(List<Donation> serverData, {bool isHistoryView = false}) {
    // 🛡️ Step A: Keep ONLY the manual seeds from the existing list
    // final List<Donation> existingSeeds = _items
    //  .where((d) =>
    //     d.donorName == 'Featured Listing' ||
    //    d.donorName == 'Community Kitchen' ||
    //d.donorName == 'Ramesh Kumar')
    // .toList();

    // 🛡️ Step B: Wipe the list and add the fresh server data
    _items.clear();
    _items.addAll(serverData);

    // 🛡️ Step C: Put the seeds back so the Home Screen is never empty!

    seedDemo();

    //_items.addAll(existingSeeds);

    // Sort: Newest posts (real data) at the top
    _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  void addDonation(Donation d) {
    _items.insert(0, d);
    notifyListeners();
  }

  void removeDonation(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void seedDemo() {
    // Check if Seed #1 already exists by ID to prevent duplication
    if (_items.any((d) => d.id == 'seed_1')) return;

    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    addDonation(Donation(
      id: 'seed_1', // Fixed ID
      donorName: 'Featured Listing',
      foodName: 'Donation Drive',
      phone: '+91 9876543210',
      pickupLocation: 'Central Park',
      pickupWindow: '30 mins',
      category: 'Cooked Meals',
      quantity: "20",
      photoPaths: ['assets/images/sample1.jpg'],
      preparedTime: 'Yesterday',
      expiryTime: 'Today',
      hygieneConfirmed: true,
      createdAt: yesterday, // Force seeds to the bottom
      isNew: false,
    ));

    // 2️⃣ Community Kitchen
    addDonation(Donation(
      id: 'seed_2',
      donorName: 'Community Kitchen',
      foodName: 'Rice & Curry',
      phone: '+91 9123456789',
      pickupLocation: 'Greenwood Street',
      pickupWindow: 'Today 9am - 12pm',
      category: 'Vegetables',
      quantity: "35",
      photoPaths: ['assets/images/sample2.png'],
      hygieneConfirmed: true, // ✅ RESTORED
      preparedTime: '6hrs ago',
      expiryTime: 'Tomorrow',
      createdAt: yesterday.add(const Duration(minutes: 5)),
      isNew: false,
    ));

    // 3️⃣ SEED: BAKERY SURPLUS
    addDonation(Donation(
      id: 'seed_3',
      donorName: 'Ramesh Kumar',
      foodName: 'Bakery Surplus',
      phone: '+91 9988776655',
      pickupLocation: 'Baker Street',
      pickupWindow: 'tomorrow 12 - 3pm',
      category: 'Baked Items',
      quantity: "15",
      photoPaths: ['assets/images/sample3.jpg'],
      hygieneConfirmed: true, // ✅ RESTORED
      preparedTime: 'Afternoon',
      expiryTime: 'Tonight',
      createdAt: yesterday.add(const Duration(minutes: 10)),
      isNew: false,
    ));
  }
}
