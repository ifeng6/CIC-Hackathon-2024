import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smart_macro/models/receipt.dart';
import 'package:smart_macro/utils/http_utils.dart';

class ReceiptLoadingPage extends StatefulWidget {

  const ReceiptLoadingPage({Key? key}) : super(key: key);

  @override
  _ReceiptLoadingPageState createState() => _ReceiptLoadingPageState();
}

class _ReceiptLoadingPageState extends State<ReceiptLoadingPage> {
  var userProfileBox = Hive.box('userProfile');

  @override
  void initState() {
    super.initState();
    _getReceipts();
  }

  Future<void> _getReceipts() async {
    try {
      int userId = userProfileBox.get("userId", defaultValue: 1);
      Map<String, dynamic> response = await getReceiptsFromAWS(<String, dynamic>{'userId': userId,});

      // Call receipt page here
      List<Receipt> receipts = [];
      
    } catch (error) {
      print("Error processing image: $error");
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
        ), // Show the loading indicator
      ),
    );
  }
}
