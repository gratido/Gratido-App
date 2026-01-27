import '../models/food_item.dart';

class DummyFoodRepo {
  static List<FoodItem> getFoodItems() {
    return [
      FoodItem(
        id: '1',
        title: 'Vegetable Biryani',
        category: 'Cooked Meals',
        images: ['assets/images/r1.jpeg'],
        quantity: '200',
        expiry: 'Tomorrow 1pm',
        pickupTime: '9:00 PM',
        location: 'Moulali',
      ),
      FoodItem(
        id: '2',
        title: 'Chapati',
        category: 'Cooked Meals',
        images: ['assets/images/r2.jpeg'],
        quantity: '450',
        expiry: 'Today',
        pickupTime: 'Today 3pm',
        location: 'City Cente',
      ),
      FoodItem(
        id: '3',
        title: 'Snacks Mix',
        category: 'Snacks',
        images: ['assets/images/r3.jpeg'],
        quantity: '100',
        expiry: '26-03-26',
        pickupTime: '7:30 PM',
        location: 'City Center',
      ),
      FoodItem(
        id: '4',
        title: 'Veg Puffs',
        category: 'Bakery',
        images: ['assets/images/r4.jpeg'],
        quantity: '4',
        expiry: 'Today',
        pickupTime: '6:30 PM',
        location: 'City Center',
      ),
      FoodItem(
        id: '5',
        title: 'Evening Snacks',
        category: 'Snacks',
        images: ['assets/images/r5.jpeg'],
        quantity: '3',
        expiry: 'Today',
        pickupTime: '5:30 PM',
        location: 'City Center',
      ),
    ];
  }
}
