import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smart_macro/components/text_field.dart';
import 'package:smart_macro/models/activity_level.dart';

class ViewProfilePage extends StatefulWidget {
  @override
  _ViewProfilePageState createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  ActivityLevel? selectedActivityLevel;

  bool isEditingName = false;
  bool isEditingAge = false;
  bool isEditingHeight = false;
  bool isEditingWeight = false;
  bool isEditingActivityLevel = false;

  var userProfileBox = Hive.box('userProfile');
  int? userId;

  @override
  void initState() {
    super.initState();
    loadProfileData();
    userId = userProfileBox.get("userId", defaultValue: 1);
  }

  void loadProfileData() {
    var userProfile = Hive.box("userProfile");
    nameController.text = userProfile.get("name", defaultValue: "") as String;
    ageController.text = userProfile.get("age", defaultValue: "0").toString();
    heightController.text = userProfile.get("height", defaultValue: "0").toString();
    weightController.text = userProfile.get("weight", defaultValue: "0").toString();
    selectedActivityLevel = stringToActivityLevel(userProfile.get("activitylevel", defaultValue: ""));
  }

  void saveProfileData() {
    var userProfile = Hive.box("userProfile");
    userProfile.put("name", nameController.text);
    userProfile.put("age", int.parse(ageController.text));
    userProfile.put("height", int.parse(heightController.text));
    userProfile.put("weight", int.parse(weightController.text));
    userProfile.put("activitylevel", activityLevelToString(selectedActivityLevel!));
  }

  void toggleEditing(String field) {
    setState(() {
      if (field == 'name') {
        if (isEditingName) {
          saveProfileData();
        }
        isEditingName = !isEditingName;
      } else if (field == 'age') {
        if (isEditingAge) {
          saveProfileData();
        }
        isEditingAge = !isEditingAge;
      } else if (field == 'height') {
        if (isEditingHeight) {
          saveProfileData();
        }
        isEditingHeight = !isEditingHeight;
      } else if (field == 'weight') {
        if (isEditingWeight) {
          saveProfileData();
        }
        isEditingWeight = !isEditingWeight;
      } else if (field == 'activityLevel') {
        isEditingActivityLevel = !isEditingActivityLevel;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (userId != null)...[
                const SizedBox(height: 20),
                Center(
                  child: Text("User Id: ${userId.toString()}", style: TextStyle(color: Colors.black, fontSize: 20)),
                )
              ],
              const SizedBox(height: 45),

              // Name Field
              buildProfileField('Name', nameController, isEditingName, 'name'),
              const SizedBox(height: 16),

              // Age Field
              buildProfileField('Age', ageController, isEditingAge, 'age'),
              const SizedBox(height: 16),

              // Height Field
              buildProfileField('Height (cm)', heightController, isEditingHeight, 'height'),
              const SizedBox(height: 16),

              // Weight Field
              buildProfileField('Weight (kg)', weightController, isEditingWeight, 'weight'),
              const SizedBox(height: 16),

              // Activity Level Field
              buildActivityLevelField(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileField(String label, TextEditingController controller, bool isEditing, String field) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: isEditing
              ? AppTextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  isObscure: false,
                  label: label,
                )
              : Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    controller.text,
                    style: TextStyle(fontSize: 18), // Increased font size
                  ),
                ),
        ),
        IconButton(
          icon: Icon(isEditing ? Icons.save : Icons.edit),
          color: isEditing ? Colors.green[300] : Colors.grey[700],
          onPressed: () => toggleEditing(field),
        ),
      ],
    );
  }

  Widget buildActivityLevelField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: isEditingActivityLevel
              ? DropdownButtonFormField<ActivityLevel>(
                  value: selectedActivityLevel,
                  items: ActivityLevel.values.map((ActivityLevel level) {
                    return DropdownMenuItem<ActivityLevel>(
                      value: level,
                      child: Text(activityLevelToString(level)),
                    );
                  }).toList(),
                  onChanged: (ActivityLevel? newValue) {
                    setState(() {
                      selectedActivityLevel = newValue;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.grey, // Change this to your desired color
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: Colors.grey, // Change this to your desired color for focused state
                        width: 1.0,
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    activityLevelToString(selectedActivityLevel!),
                    style: TextStyle(fontSize: 18), // Increased font size
                  ),
                ),
        ),
        IconButton(
          icon: Icon(isEditingActivityLevel ? Icons.save : Icons.edit),
          color: isEditingActivityLevel ? Colors.green[300] : Colors.grey[700],
          onPressed: () => toggleEditing('activityLevel'),
        ),
      ],
    );
  }

}
