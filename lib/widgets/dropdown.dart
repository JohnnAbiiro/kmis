import 'package:flutter/material.dart';

// Widget buildDropdown({
//   required String? value,
//   required List<String> items,
//   required String label,
//   required Color fillColor,
//   required Function(String?) onChanged,
//   required String validatorMsg,
// }) {
//   return DropdownButtonFormField<String>(
//     value: value,
//     items: items
//         .map((e) => DropdownMenuItem(
//       value: e,
//       child: Text(e),
//     ))
//         .toList(),
//     dropdownColor: fillColor,
//     onChanged: onChanged,
//     decoration: InputDecoration(
//       labelText: label,
//       labelStyle: const TextStyle(color: Colors.black),
//       border: const OutlineInputBorder(),
//       contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//       filled: true,
//       fillColor: fillColor,
//     ),
//     style: TextStyle(color: Colors.black),
//     validator: (v) => v == null || v.isEmpty ? validatorMsg : null,
//   );
// }

Widget buildDropdown({
  required String? value,
  required List<String> items,
  required String label,
  required Color fillColor,
  required ValueChanged<String?> onChanged,
  required String validatorMsg,
}) {
  // Only pass a value if it actually exists in items; otherwise null.
  final safeValue = (value != null && items.contains(value)) ? value : null;

  return DropdownButtonFormField<String>(
    value: safeValue,
    items: items.toSet()
        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
        .toList(),
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: fillColor,
      border: const OutlineInputBorder(),
    ),
    validator: (v) => v == null ? validatorMsg : null,
  );
}