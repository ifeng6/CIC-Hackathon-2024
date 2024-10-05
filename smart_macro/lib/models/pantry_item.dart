import 'package:smart_macro/models/item_type.dart';

class PantryItem {
  final String name;          // Name of the pantry item
  final ItemType type;       // Type of the pantry item (countable, liquid, weight)
  final double quantity;      // Quantity of the pantry item (can be in kg, ml, or count)
  final int daysLeftToExpire; // Days left until expiration

  // Constructor
  PantryItem({
    required this.name,
    required this.type,
    required this.quantity,
    required this.daysLeftToExpire,
  });

  // Optional: You can add a method to display item information
  @override
  String toString() {
    return 'PantryItem(name: $name, type: $type, quantity: $quantity, daysLeftToExpire: $daysLeftToExpire)';
  }

  // Factory constructor to create a PantryItem from JSON
  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      name: json['name'] as String,
      type: stringToItem(json['type'] as String),
      quantity: json['quantity'],
      daysLeftToExpire: json['daysLeftToExpire'] as int,
    );
  }
}
