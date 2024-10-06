import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:smart_macro/models/macro.dart';
import 'package:smart_macro/models/pantry_item.dart';
import 'package:smart_macro/models/receipt.dart';
import 'package:smart_macro/screens/receipt_screen.dart';
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

      for (var receipt in response['receipts']) {
        receipts.add(await makeReceipt(receipt));
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ReceiptScreen(receipts: receipts)),
      );
    } catch (error) {
      print("Error processing image: $error");
      // Optionally, handle the error (e.g., show a dialog, navigate back, etc.)
      Fluttertoast.showToast(
        msg: "Error occured",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Navigator.pop(context); // Close this page if there's an error
    }
  }

  Future<Receipt> makeReceipt(Map<String, dynamic> response) async {
    // Extract macros
    Macro macros = Macro.fromJson(response['macros']);

    // Extract pantry items
    List<PantryItem> pantryItems = (response['items'] as List)
        .map((item) => PantryItem.fromJson(item))
        .toList();

    double cost = response['cost'].toDouble();

    // You can now use the macros and pantryItems
    print('Macros: $macros');
    print('Pantry Items: $pantryItems');

    return Receipt(macros: macros, items: pantryItems, cost: cost);
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
