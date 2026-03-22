class FoodItem {
  final String id;
  final String title;
  final String category;
  final List<String> images;
  final String quantity;
  final String expiry;
  final String pickupTime;
  final String location;
  final double latitude;
  final double longitude;

  final String phone;
  final String notes;

  FoodItem({
    required this.id,
    required this.title,
    required this.category,
    required this.images,
    required this.quantity,
    required this.expiry,
    required this.pickupTime,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.notes,
  });

  // ✅ NEW: Map Backend JSON to Flutter Model
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'].toString(),

      // ✅ FIXED TITLE MAPPING
      title: json['foodTitle'] ?? json['title'] ?? json['Title'] ?? "No Title",

      category: json['category'] ?? json['Category'] ?? "General",

      // ✅ SAFE image parsing
      images: json['imageUrls'] != null
          ? (json['imageUrls'] as String).split(',')
          : [],

      quantity: json['quantity']?.toString() ?? "0",

      expiry: json['expiryDateText'] ?? json['expiry'] ?? "N/A",

      pickupTime: json['pickupWindow'] ?? json['pickupTime'] ?? "Anytime",

      location: json['address'] ?? json['location'] ?? "No Address",

      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),

      phone: json['donorPhone'] ?? json['phone'] ?? "N/A",
      notes: json['notes'] ?? "",
    );
  }
}
