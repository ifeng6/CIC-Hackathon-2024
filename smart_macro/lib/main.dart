import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_macro/screens/create_profile.dart';
import 'package:smart_macro/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('userProfile');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var userProfileBox = Hive.box('userProfile');
    // bool hasProfile = userProfileBox.get("hasProfile", defaultValue: false);
    bool hasProfile = false;

    return MaterialApp(
      title: 'Receipt App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.grey, 
      ),
      // Directly set HomeScreen as the initial page
      home: hasProfile
          ? ReceiptScannerPage()
          : CreateProfilePage(), 
      debugShowCheckedModeBanner: false, 
    );
  }
}
