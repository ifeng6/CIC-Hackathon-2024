import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smart_macro/models/pantry_item.dart';
import 'package:smart_macro/utils/http_utils.dart';

class PantryLoadingPage extends StatefulWidget {
  const PantryLoadingPage({Key? key}) : super(key: key);

  @override
  _PantryLoadingPageState createState() => _PantryLoadingPageState();
}

class _PantryLoadingPageState extends State<PantryLoadingPage> {
  var userProfileBox = Hive.box('userProfile');

  @override
  void initState() {
    super.initState();
    _getPantryItems();
  }

  Future<void> _getPantryItems() async {
    try {
      int userId = userProfileBox.get("userId", defaultValue: 1);
      Map<String, dynamic> response = await getPantryFromAWS(<String, dynamic>{'userId': userId});

      // Assuming the response contains a list of pantry items
      List<PantryItem> pantryItems = (response['items'] as List).map((item) => PantryItem.fromJson(item)).toList();

      // Navigate to PantryScreen with the list of pantry items
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => PantryScreen(pantryItems: pantryItems),
      //   ),
      // );

    } catch (error) {
      print("Error fetching pantry items: $error");
      // Optionally, handle the error (e.g., show a dialog, navigate back, etc.)

      // Navigator.pop(context); // Close this page if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.green[200], // Customize the color of the loading indicator
        ),
      ), // Show the loading indicator
    );
  }
}
