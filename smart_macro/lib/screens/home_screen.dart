import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
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
    // final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    // if (image != null) {
    //   // Process the image (e.g., display it on the screen or send it to a server for OCR)
    //   print('Image path: ${image.path}');
    // }
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
                  padding: const EdgeInsets.all(16.0),
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
          height: 80, // Increased height of the bottom bar
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
                  // Navigate to ReceiptScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReceiptScreen()),
                  );
                },
              ),
              SizedBox(width: 48), // Space for the floating action button
              IconButton(
                icon: Icon(Icons.favorite_border),
                iconSize: 32, // Adjusted icon size
                color: Colors.grey[800],
                onPressed: () {
                  // Navigate to FavouritesScreen
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => FavouritesScreen()),
                  // );
                },
              ),
            ],
          ),
        ),
      ),

    );
  }
}