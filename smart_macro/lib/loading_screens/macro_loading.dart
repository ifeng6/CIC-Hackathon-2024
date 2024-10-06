import 'dart:io';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // Import for Base64 encoding
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:smart_macro/models/macro.dart';
import 'package:smart_macro/models/pantry_item.dart';
import 'package:smart_macro/screens/macro_screen.dart';
import 'package:smart_macro/utils/http_utils.dart';

class MacroLoadingPage extends StatefulWidget {
  final XFile xFile;
  const MacroLoadingPage({Key? key, required this.xFile}) : super(key: key);

  @override
  _MacroLoadingPageState createState() => _MacroLoadingPageState();
}

class _MacroLoadingPageState extends State<MacroLoadingPage> {
  var userProfileBox = Hive.box('userProfile');

  @override
  void initState() {
    super.initState();
    _sendImage();
  }

  Future<void> _sendImage() async {
    // Optionally, convert to JPEG
    // final img.Image originalImage = await img.decodeImage(await widget.imageFile.readAsBytes())!;
    // final List<int> jpeg = await img.encodeJpg(originalImage);
    
    // // Convert JPEG byte array to Base64 string
    // String base64String = base64Encode(jpeg);

    // Print the Base64 string (can be very long, consider logging its length instead)
    // print("Base64 JPEG String: $base64String");
    // print("Base64 Length: ${base64String.length}");

    // Optionally, send the Base64 string to the OCR server
    Map<String, dynamic> response = await sendOcrData(widget.xFile, userProfileBox.get("userId", defaultValue: 111111).toString());
    // Extract macros
    print("HERE");
    Macro macros = Macro.fromJson(response['macros']);

    // Extract pantry items
    List<PantryItem> pantryItems = (response['items'] as List)
        .map((item) => PantryItem.fromJson(item))
        .toList();

    // You can now use the macros and pantryItems
    print('Macros: $macros');
    print('Pantry Items: $pantryItems');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MacroScreen(
          pantryItems: pantryItems, // Replace with your pantry items list
          macro: macros, // Replace with your Macro object
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: CircularProgressIndicator(color: Colors.green[200]) // Show the loading indicator
      ),
    );
  }
}