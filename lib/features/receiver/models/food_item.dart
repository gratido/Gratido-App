class FoodItem {
  final String id;
  final String title;
  final String category;
  final List<String> images;
  final String quantity;
  final String expiry;
  final String pickupTime;
  final String location;

  FoodItem({
    required this.id,
    required this.title,
    required this.category,
    required this.images,
    required this.quantity,
    required this.expiry,
    required this.pickupTime,
    required this.location,
  });

  // ✅ NEW: Map Backend JSON to Flutter Model
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'].toString(),
      title: json['foodTitle'] ?? "No Title",
      category: json['category'] ?? "General",
      // Handles comma-separated string from C#
      images: (json['imageUrls'] as String).split(','),
      quantity: json['quantity'] ?? "0",
      expiry: json['expiryDateText'] ?? "N/A",
      pickupTime: json['pickupWindow'] ?? "Anytime",
      location: json['address'] ?? "No Address",
    );
  }
}
