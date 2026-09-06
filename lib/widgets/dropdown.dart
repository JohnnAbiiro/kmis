
import 'package:flutter/material.dart';

class DropdownWidget {
  static Widget buildDropdown({
    required BuildContext dropdownContext,
    required String? value,
    required List<String> items,
    required String label,
    required Color fillColor,
    required ValueChanged<String?> onChanged,
    required String validatorMsg,
  }) {
    final safeValue = (value != null && items.contains(value)) ? value : null;

    return DropdownButtonFormField<String>(
      initialValue: safeValue,
      items: items.toSet()
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(dropdownContext).colorScheme.onSurface),
        filled: true,
        fillColor: fillColor,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(dropdownContext).colorScheme.outline.withValues(alpha: 0.5)),
        ),
      ),
      validator: (v) => v == null ? validatorMsg : null,
    );
  }
}