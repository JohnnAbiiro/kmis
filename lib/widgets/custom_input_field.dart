import 'package:flutter/material.dart';

InputDecoration inputStyle(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.grey.shade100,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
  );
}

Widget customField({
  required TextEditingController controller,
  required String label,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    decoration: inputStyle(label),
  );
}
