import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:smart_macro/models/activity_level.dart';
import 'package:smart_macro/screens/home_screen.dart';
import 'package:smart_macro/utils/http_utils.dart';


class ProfileLoadingScreen extends StatefulWidget {
  final int userId;
  final int height; // Height in cm
  final int age;    // Age in years
  final int weight; // Weight in kg
  final ActivityLevel activityLevel; // Activity level

  const ProfileLoadingScreen({
    Key? key,
    required this.userId,
    required this.height,
    required this.age,
    required this.weight,
    required this.activityLevel,
  }) : super(key: key);

  @override
  _ProfileLoadingScreenState createState() => _ProfileLoadingScreenState();
}

class _ProfileLoadingScreenState extends State<ProfileLoadingScreen> {
  var userProfileBox = Hive.box('userProfile');

  @override
  void initState() {
    super.initState();
    _sendProfileData();
  }

  Future<void> _sendProfileData() async {
    try {
      int userId = userProfileBox.get("userId", defaultValue: 1);
      Map<String, dynamic> response = await getProfileMacros(
        <String, dynamic>{
          "userId": widget.userId,
          "height": widget.height,
          "age": widget.age,
          "weight": widget.weight,
          "activitylevel": activityLevelToString(widget.activityLevel)
        }
      );  

      print(response);

      double calories = response['calories'];
      double protein = response['protein'];
      double fats = response['fat'];
      double carbs = response['carbs'];

      // Add the stuff in the hive box
      userProfileBox.put("calories", calories);
      userProfileBox.put("protein", protein);
      userProfileBox.put("fats", fats);
      userProfileBox.put("carbs", carbs);

      // Assuming you receive a response and need to navigate to the next page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ReceiptScannerPage()),
      );

    } catch (error) {
      print("Error sending profile data: $error");
      // Optionally handle the error
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
