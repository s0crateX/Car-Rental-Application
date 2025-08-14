import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class CarDetailsSectionWidget extends StatefulWidget {
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  final TextEditingController typeController;

  const CarDetailsSectionWidget({
    super.key,
    required this.brandController,
    required this.modelController,
    required this.yearController,
    required this.typeController,
  });

  @override
  State<CarDetailsSectionWidget> createState() =>
      _CarDetailsSectionWidgetState();
}

class _CarDetailsSectionWidgetState extends State<CarDetailsSectionWidget> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextFormField(
                controller: widget.brandController,
                label: 'Brand',
                hint: 'e.g. Toyota',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFormField(
                controller: widget.typeController,
                label: 'Type',
                hint: 'e.g. Sedan',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextFormField(
                controller: widget.modelController,
                label: 'Model',
                hint: 'e.g. Camry',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFormField(
                controller: widget.yearController,
                label: 'Year',
                hint: 'e.g. 2023',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: AppTheme.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: 'General Sans',
        letterSpacing: 0.15,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        labelText: label,
        hintText: hint,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.red, width: 2),
        ),
        labelStyle: TextStyle(
          color: AppTheme.lightBlue.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'General Sans',
          letterSpacing: 0.1,
        ),
        hintStyle: TextStyle(
          color: AppTheme.paleBlue.withOpacity(0.6),
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
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
