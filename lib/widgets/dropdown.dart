import 'package:flutter/material.dart';

Widget buildDropdown({
  required String? value,
  required List<String> items,
  required String label,
  required Color fillColor,
  required Function(String?) onChanged,
  required String validatorMsg,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    items: items
        .map((e) => DropdownMenuItem(
      value: e,
      child: Text(e),
    ))
        .toList(),
    dropdownColor: fillColor,
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black),
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      filled: true,
      fillColor: fillColor,
    ),
    style: TextStyle(color: Colors.black),
    validator: (v) => v == null || v.isEmpty ? validatorMsg : null,
  );
}