import 'package:flutter/material.dart';

Widget buildTextField(String label, ValueChanged<String?> onSaved,
    {bool validator = false, bool isMultiline = false, String? initialValue}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
      ),
      onChanged: onSaved,
      validator: validator
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            }
          : null,
      maxLines:
          isMultiline ? null : 1, // Set maxLines to null for multiline input
    ),
  );
}
