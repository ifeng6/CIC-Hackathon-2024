class Macro {
  final double protein; // in grams
  final double carbohydrates; // in grams
  final double fats; // in grams

  Macro({
    required this.protein,
    required this.carbohydrates,
    required this.fats,
  });

  // Method to calculate total calories from macronutrients
  double totalCalories() {
    return (protein * 4) + (carbohydrates * 4) + (fats * 9);
  }

  // Method to represent the Macro as a string
  @override
  String toString() {
    return 'Macro(protein: $protein g, carbohydrates: $carbohydrates g, fats: $fats g)';
  }

  // Method to convert a JSON object to a Macro instance
  factory Macro.fromJson(Map<String, dynamic> json) {
    return Macro(
      protein: json['protein']?.toDouble() ?? 0.0,
      carbohydrates: json['carbohydrates']?.toDouble() ?? 0.0,
      fats: json['fats']?.toDouble() ?? 0.0,
    );
  }

  // Method to convert Macro instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'carbohydrates': carbohydrates,
      'fats': fats,
    };
  }
}
