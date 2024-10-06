import 'package:smart_macro/models/item_type.dart';

class PantryItem {
  final String name;          // Name of the pantry item
  final double quantity;      // Quantity of the pantry item (can be in kg, ml, or count)
  final int daysLeftToExpire; // Days left until expiration

  // Constructor
  PantryItem({
    required this.name,
    required this.quantity,
    required this.daysLeftToExpire,
  });

  // Optional: You can add a method to display item information
  @override
  String toString() {
    return 'PantryItem(name: $name, quantity: $quantity, daysLeftToExpire: $daysLeftToExpire)';
  }

  // Factory constructor to create a PantryItem from JSON
  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      name: json['name'] as String,
      quantity: json['quantity'].toDouble(),
      daysLeftToExpire: json['days_left'] as int,
    );
  }
}
