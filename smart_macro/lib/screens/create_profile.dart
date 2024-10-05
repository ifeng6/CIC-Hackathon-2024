import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smart_macro/components/text_field.dart';
import 'package:smart_macro/loading_screens/profile_loading.dart';
import 'package:smart_macro/models/activity_level.dart';
import 'package:smart_macro/screens/home_screen.dart';

class CreateProfilePage extends StatefulWidget {
  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  ActivityLevel? selectedActivityLevel; // Variable to hold the selected activity level

  // Method to check if the button should be enabled
  bool isButtonEnabled() {
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim());
    final height = int.tryParse(heightController.text.trim());
    final weight = int.tryParse(weightController.text.trim());
    
    // Check that fields are filled and valid
    return name.isNotEmpty &&
           age != null && age > 0 &&
           height != null && height > 0 &&
           weight != null && weight > 0 &&
           selectedActivityLevel != null; // Ensure activity level is selected
  }

  int generateRandomId() {
    final Random random = Random();
    int userId = random.nextInt(900000) + 100000; // Generates a number between 100000 and 999999
    return userId;
  }


  void onPressed() {
      var userProfile = Hive.box("userProfile");
      int userId = generateRandomId();
      userProfile.put("userId", userId);
      userProfile.put("name", nameController.text);
      userProfile.put("age", int.parse(ageController.text));
      userProfile.put("height", int.parse(heightController.text));
      userProfile.put("weight", int.parse(weightController.text));
      userProfile.put("activitylevel", activityLevelToString(selectedActivityLevel!));
      userProfile.put("hasProfile", true);


      // Corrected parentheses for Navigator.pushReplacement
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileLoadingScreen(
            userId: userId,
            height: int.parse(heightController.text),
            age: int.parse(ageController.text),
            weight: int.parse(weightController.text),
            activityLevel: selectedActivityLevel!
          ),
        ),
      );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Profile!'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon at the top of the page
              Center(
                child: Container(
                  width: 100, // Width of the circle
                  height: 100, // Height of the circle
                  decoration: BoxDecoration(
                    color: Colors.green[400], // Circle background color
                    shape: BoxShape.circle, // Make it a circle
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_add,
                      size: 50, // Adjusted icon size
                      color: Colors.white, // Icon color set to white
                    ),
                  ),
                ),
              ),
          
              const SizedBox(height: 45), // Space between icon and fields
          
              // Text field for Name
              AppTextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                isObscure: false,
                label: 'Name',
              ),
              const SizedBox(height: 16), // Space between fields
          
              // Text field for Age
              AppTextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                isObscure: false,
                label: 'Age',
              ),
              const SizedBox(height: 16), // Space between fields
          
              // Text field for Height
              AppTextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                isObscure: false,
                label: 'Height (cm)',
              ),
              const SizedBox(height: 16), // Space between fields
          
              // Text field for Weight
              AppTextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                isObscure: false,
                label: 'Weight (kg)',
              ),
              const SizedBox(height: 30), // Space between fields
          
              // Dropdown for Activity Level
              SizedBox(
                width: double.infinity, // Make dropdown the same width as text fields
                child: DropdownButtonFormField<ActivityLevel>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300], // Set your desired background color here
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0), // Optional: Customize border radius
                      borderSide: BorderSide.none, // Optional: Remove the border line
                    ),
                  ),
                  hint: Text('Select Activity Level'),
                  value: selectedActivityLevel,
                  isExpanded: true, // Expand dropdown to fill the width
                  items: ActivityLevel.values.map((ActivityLevel level) {
                    return DropdownMenuItem<ActivityLevel>(
                      value: level,
                      child: Text(activityLevelToString(level)), // Use the function to convert enum to string
                    );
                  }).toList(),
                  onChanged: (ActivityLevel? newValue) {
                    setState(() {
                      selectedActivityLevel = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 30), // Space before button
          
          
              // Centered Done Button
              Center(
                child: ElevatedButton(
                  onPressed: isButtonEnabled() ? onPressed : null,
                  child: Text("Done", style: TextStyle(fontSize: 25, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400], // Set the background color to green
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Optional: adjust padding
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}