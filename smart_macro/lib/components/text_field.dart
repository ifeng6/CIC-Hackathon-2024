import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    Key? key,
    required this.controller,
    required this.keyboardType,
    required this.isObscure,
    required this.label,
  }) : super(key: key);

  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isObscure;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isObscure,
      obscuringCharacter: '●', // Optional obscuring character
      cursorColor: Colors.black, // Cursor color when text field is selected
      style: const TextStyle(color: Colors.black), // Black text color
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // White fill color
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 6.0,
        ),
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black54, // Slightly transparent label text
        ),
        // Default border (grey)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        ),
        // Focused border (green)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
          borderSide: const BorderSide(color: Colors.green, width: 2.0),
        ),
        // Error border (optional, can be adjusted)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
        // Error focused border (optional, can be adjusted)
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
        ),
      ),
    );
  }
}
