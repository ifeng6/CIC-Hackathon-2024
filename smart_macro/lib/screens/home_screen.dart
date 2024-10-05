import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_macro/loading_screens/macro_loading.dart';
import 'package:smart_macro/loading_screens/pantry_loading.dart';
import 'package:smart_macro/loading_screens/receipt_loading.dart';
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

  @override
  void initState() {
    super.initState();
    name = userProfileBox.get("name", defaultValue: null);
  }

  Future<void> _scanReceipt() async {
    final XFile? xFile = await _picker.pickImage(source: ImageSource.camera);
    
    if (xFile != null) {
      // Convert XFile to File
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
      backgroundColor: Color(0xFFF5F7FA), // Background similar to your image
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile icon at the top left
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Use min to wrap the contents
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
                      // Display the name if it's not null
                      if (name != null) // Ensure `name` is defined in your context
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0), // Add some space between icon and name
                          child: Text(
                            name!, // Use the variable that contains the name
                            style: TextStyle(
                              fontSize: 18, // You can adjust the font size as needed
                              color: Colors.grey[700], // Match the color with the icon
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 20),
                // Center content
                Expanded(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Light grey rounded box
                        borderRadius: BorderRadius.circular(30),
                      ),
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Scanning icon
                          Icon(
                            Icons.camera_alt,
                            size: 80, // Adjust the size as needed
                            color: Colors.blue,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Scan Grocery Receipts',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'We will generate recipes and notify you when your groceries are about to expire.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // Rounded corner box at the bottom with three icon buttons
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _scanReceipt, // Action for Scan button
        child: Icon(Icons.camera_alt),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners for the FAB
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: Container(
          height: 100, // Increased height of the bottom bar
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200], // Light grey color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), // Rounded corners for the box
              topRight: Radius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.receipt_long),
                iconSize: 32, // Adjusted icon size
                color: Colors.grey[800],
                onPressed: () {
                  // Navigate to ReceiptLoadingPage
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => ReceiptLoadingPage()),
                  // );


                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReceiptScreen(receipts: _generateSampleReceipts(),)),
                  );
                },
              ),
              SizedBox(width: 48), // Space for the floating action button
              IconButton(
                icon: Icon(Icons.local_grocery_store),
                iconSize: 32, // Adjusted icon size
                color: Colors.grey[800],
                onPressed: () {
                  // // Navigate to PantryLoadingPage
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => PantryLoadingPage()),
                  // );

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
}