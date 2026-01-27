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
}
