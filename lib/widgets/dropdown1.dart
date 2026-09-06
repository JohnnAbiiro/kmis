import 'package:flutter/material.dart';

Widget buildDropdown({
  required String? value,
  required List<String> items,
  required String label,
  required Color fillColor,
  required ValueChanged<String?>? onChanged,
  required String validatorMsg,
}) {
  final safeValue = (value != null && items.contains(value)) ? value : null;

  return DropdownButtonFormField<String>(
    value: safeValue,
    items: items.toSet()
        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
        .toList(),
    onChanged: onChanged,   // now nullable → nullable, matches fine
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: fillColor,
      border: const OutlineInputBorder(),
    ),
    validator: (v) => v == null ? validatorMsg : null,
  );
}