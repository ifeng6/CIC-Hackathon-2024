import 'dart:io';
import 'dart:convert'; // Import for Base64 encoding
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:smart_macro/utils/http_utils.dart';

class MacroLoadingPage extends StatefulWidget {
  final File imageFile;
  const MacroLoadingPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  _MacroLoadingPageState createState() => _MacroLoadingPageState();
}

class _MacroLoadingPageState extends State<MacroLoadingPage> {
  @override
  void initState() {
    super.initState();
    _sendImage();
  }

  Future<void> _sendImage() async {
    // Optionally, convert to JPEG
    final img.Image originalImage = await img.decodeImage(await widget.imageFile.readAsBytes())!;
    final List<int> jpeg = await img.encodeJpg(originalImage);
    
    // Convert JPEG byte array to Base64 string
    String base64String = base64Encode(jpeg);

    // Print the Base64 string (can be very long, consider logging its length instead)
    print("Base64 JPEG String: $base64String");
    print("Base64 Length: ${base64String.length}");

    // Optionally, send the Base64 string to the OCR server
    // Map<String, dynamic> response = await sendOcrData(base64String);
    print("SENT");
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