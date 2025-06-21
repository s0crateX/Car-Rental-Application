import 'package:flutter/material.dart';
import '../../../../../config/theme.dart';

class DescriptionSectionWidget extends StatelessWidget {
  final TextEditingController descriptionController;
  const DescriptionSectionWidget({super.key, required this.descriptionController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: descriptionController,
      maxLines: 4,
      style: const TextStyle(color: AppTheme.white),
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Describe your car highlights and special features...',
        icon: const Icon(Icons.description_outlined, color: AppTheme.lightBlue),
        filled: true,
        fillColor: AppTheme.darkNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.mediumBlue.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.mediumBlue.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.lightBlue, width: 2),
        ),
        labelStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.8)),
        hintStyle: TextStyle(color: AppTheme.paleBlue.withOpacity(0.6)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }
}
