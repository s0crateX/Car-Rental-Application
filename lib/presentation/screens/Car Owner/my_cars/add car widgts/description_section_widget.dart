import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class DescriptionSectionWidget extends StatelessWidget {
  final TextEditingController descriptionController;
  const DescriptionSectionWidget({super.key, required this.descriptionController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            'Provide a detailed description of your vehicle',
            style: TextStyle(
              color: AppTheme.paleBlue.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w300,
              fontFamily: 'General Sans',
              letterSpacing: 0.25,
            ),
          ),
        ),

        // Description Input Field
        TextFormField(
          controller: descriptionController,
          maxLines: 5,
          minLines: 4,
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'General Sans',
            letterSpacing: 0.25,
            height: 2,
          ),
          decoration: InputDecoration(
            labelText: 'Vehicle Description',
            hintText: 'Add a detailed description of your vehicle',
            alignLabelWithHint: true,
            filled: true,
            fillColor: AppTheme.darkNavy,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.mediumBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.lightBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.red,
                width: 2,
              ),
            ),
            labelStyle: TextStyle(
              color: AppTheme.lightBlue.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w300,
              fontFamily: 'General Sans',
              letterSpacing: 0.25,
            ),
            hintStyle: TextStyle(
              color: AppTheme.lightBlue.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w300,
              fontFamily: 'General Sans',
              letterSpacing: 0.25,
            ),
            errorStyle: TextStyle(
              color: AppTheme.red,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'General Sans',
              letterSpacing: 0.4,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please provide a description of your vehicle';
            }
            if (value.length < 20) {
              return 'Description should be at least 20 characters long';
            }
            return null;
          },
        ),

        // Helper Text
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.lightBlue.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'A detailed description helps renters understand what makes your car special and increases booking chances.',
                  style: TextStyle(
                    color: AppTheme.paleBlue.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'General Sans',
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
