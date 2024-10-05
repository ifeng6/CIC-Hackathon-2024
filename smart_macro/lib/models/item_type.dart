enum ItemType {
  countable, // Represents items counted in units (e.g., eggs, apples)
  liquid,    // Represents liquid items measured in milliliters (ml)
  weight,    // Represents solid items measured in kilograms (kg)
}

// Converts a string to an ItemType
ItemType stringToItem(String type) {
  switch (type.toLowerCase()) {
    case 'countable':
      return ItemType.countable;
    case 'liquid':
      return ItemType.liquid;
    case 'weight':
      return ItemType.weight;
    default:
      throw ArgumentError('Invalid ItemType string: $type');
  }
}

// Converts an ItemType to a string
String itemToString(ItemType item) {
  switch (item) {
    case ItemType.countable:
      return 'Countable';
    case ItemType.liquid:
      return 'Liquid';
    case ItemType.weight:
      return 'Weight';
  }
}
