import 'dart:io';
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
    print("JPEG:" + widget.imageFile.toString());

    Map<String, dynamic> respone = await sendOcrData(jpeg);
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
