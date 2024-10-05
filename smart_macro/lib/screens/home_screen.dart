import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';  // Import FL Chart
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_macro/loading_screens/macro_loading.dart';
import 'package:smart_macro/models/item_type.dart';
import 'package:smart_macro/models/macro.dart';
import 'package:smart_macro/models/pantry_item.dart';
import 'package:smart_macro/models/receipt.dart';
import 'package:smart_macro/screens/pantry_screen.dart';
import 'package:smart_macro/screens/receipt_screen.dart';
import 'package:smart_macro/screens/view_profile.dart';

class ReceiptScannerPage extends StatefulWidget {
  @override
  _ReceiptScannerPageState createState() => _ReceiptScannerPageState();
}

class _ReceiptScannerPageState extends State<ReceiptScannerPage> {
  final ImagePicker _picker = ImagePicker();
  var userProfileBox = Hive.box('userProfile');
  String? name;
  double? calories;
  double? protein;
  double? fats;
  double? carbs;

  @override
  void initState() {
    super.initState();
    name = userProfileBox.get("name", defaultValue: null);
    calories = userProfileBox.get("calories", defaultValue: 100.0);
    protein = userProfileBox.get("protein", defaultValue: 100.0);
    fats = userProfileBox.get("fats", defaultValue: 100.0);
    carbs = userProfileBox.get("carbs", defaultValue: 100.0);
  }

  Future<void> _scanReceipt() async {
    final XFile? xFile = await _picker.pickImage(source: ImageSource.camera);
    
    if (xFile != null) {
      File imageFile = File(xFile.path);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MacroLoadingPage(imageFile: imageFile)),
      );
    }
  }

    List<Receipt> _generateSampleReceipts() {
    return [
      Receipt(
        vendor: 'Grocery Store A',
        date: '2024-10-01',
        macros: Macro(protein: 50, carbohydrates: 200, fats: 30),
        items: [
          PantryItem(name: 'Rice', type: ItemType.weight, quantity: 2, daysLeftToExpire: 365),
          PantryItem(name: 'Milk', type: ItemType.liquid, quantity: 1, daysLeftToExpire: 7),
          PantryItem(name: 'Apples', type: ItemType.countable, quantity: 5, daysLeftToExpire: 10),
        ],
      ),
      Receipt(
        vendor: 'Grocery Store B',
        date: '2024-10-02',
        macros: Macro(protein: 40, carbohydrates: 150, fats: 20),
        items: [
          PantryItem(name: 'Chicken Breast', type: ItemType.weight, quantity: 1, daysLeftToExpire: 5),
          PantryItem(name: 'Olive Oil', type: ItemType.liquid, quantity: 0.5, daysLeftToExpire: 730),
          PantryItem(name: 'Bananas', type: ItemType.countable, quantity: 6, daysLeftToExpire: 7),
        ],
      ),
      Receipt(
        vendor: 'Grocery Store C',
        date: '2024-10-03',
        macros: Macro(protein: 60, carbohydrates: 180, fats: 25),
        items: [
          PantryItem(name: 'Pasta', type: ItemType.weight, quantity: 1, daysLeftToExpire: 365),
          PantryItem(name: 'Yogurt', type: ItemType.liquid, quantity: 2, daysLeftToExpire: 14),
          PantryItem(name: 'Eggs', type: ItemType.countable, quantity: 12, daysLeftToExpire: 21),
        ],
      ),
    ];
  }

  List<PantryItem> generatePantryItems() {
    return [
      PantryItem(
        name: 'Apples',
        type: ItemType.countable,
        quantity: 5,
        daysLeftToExpire: 7,
      ),
      PantryItem(
        name: 'Milk',
        type: ItemType.liquid,
        quantity: 1.5, // in liters
        daysLeftToExpire: 2,
      ),
      PantryItem(
        name: 'Chicken Breast',
        type: ItemType.weight,
        quantity: 1.0, // in kg
        daysLeftToExpire: 3,
      ),
      PantryItem(
        name: 'Orange Juice',
        type: ItemType.liquid,
        quantity: 2.0, // in liters
        daysLeftToExpire: 5,
      ),
      PantryItem(
        name: 'Rice',
        type: ItemType.countable,
        quantity: 2, // in kg
        daysLeftToExpire: 10,
      ),
      PantryItem(
        name: 'Yogurt',
        type: ItemType.liquid,
        quantity: 0.5, // in liters
        daysLeftToExpire: 1, // Expiring soon
      ),
      PantryItem(
        name: 'Flour',
        type: ItemType.countable,
        quantity: 1, // in kg
        daysLeftToExpire: 30,
      ),
      PantryItem(
        name: 'Pasta',
        type: ItemType.countable,
        quantity: 1, // in kg
        daysLeftToExpire: 60,
      ),
      PantryItem(
        name: 'Beef',
        type: ItemType.weight,
        quantity: 1.2, // in kg
        daysLeftToExpire: 4,
      ),
      PantryItem(
        name: 'Cheese',
        type: ItemType.liquid,
        quantity: 0.3, // in kg
        daysLeftToExpire: 8,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.person_outline,
                    size: 32,
                    color: Colors.grey[700],
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewProfilePage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (name != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Text(
                        'Welcome, $name!',  // Dynamic welcome message
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 15),

            // Instructions block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Take photos of receipts to add items to your pantry!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'Macronutrient Breakdown',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Center content with pie chart and legend
            Expanded(
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pie chart widget
                      SizedBox(
                        height: 200, // Adjust height as necessary
                        child: PieChart(
                          PieChartData(
                            sections: showingSections(),
                            centerSpaceRadius: 30,
                            sectionsSpace: 0,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Add color legend here
                      _buildColorLegend(),
                      SizedBox(height: 20),

                      Text(
                        '${calories?.toInt() ?? 0} Calories',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _scanReceipt,
        child: Icon(Icons.camera_alt),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.receipt_long),
                iconSize: 32,
                color: Colors.grey[800],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReceiptScreen(receipts: _generateSampleReceipts(),)),
                  );
                },
              ),
              SizedBox(width: 48),
              IconButton(
                icon: Icon(Icons.local_grocery_store),
                iconSize: 32,
                color: Colors.grey[800],
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PantryScreen(pantryItems: generatePantryItems(),)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the color legend for the pie chart
  Widget _buildColorLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legend:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildLegendColorCircle(Colors.blue),
            SizedBox(width: 8),
            Text('Protein'),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _buildLegendColorCircle(Colors.green),
            SizedBox(width: 8),
            Text('Carbohydrates'),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _buildLegendColorCircle(Colors.orange),
            SizedBox(width: 8),
            Text('Fats'),
          ],
        ),
      ],
    );
  }

  // Helper method to create a circular color legend item
  Widget _buildLegendColorCircle(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle, // Makes the container circular
      ),
    );
  }


  List<PieChartSectionData> showingSections() {
    final List<PieChartSectionData> sections = [];
    const colorMap = {
      'protein': Colors.blue,
      'carbs': Colors.orange,
      'fats': Colors.green,
    };

    // Protein section
    if (protein! > 0) {
      sections.add(PieChartSectionData(
        value: protein!,
        color: colorMap['protein']!,
        title: '${protein!.toInt()}g',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ));
    }

    // Carbs section
    if (carbs! > 0) {
      sections.add(PieChartSectionData(
        value: carbs!,
        color: colorMap['carbs']!,
        title: '${carbs!.toInt()}g',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ));
    }

    // Fats section
    if (fats! > 0) {
      sections.add(PieChartSectionData(
        value: fats!,
        color: colorMap['fats']!,
        title: '${fats!.toInt()}g',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      ));
    }

    return sections;
  }
}
