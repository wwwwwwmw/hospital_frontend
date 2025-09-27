import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?) validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? icon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
