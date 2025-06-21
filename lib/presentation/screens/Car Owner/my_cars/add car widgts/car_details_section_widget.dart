import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class CarDetailsSectionWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController yearController;
  const CarDetailsSectionWidget({
    super.key,
    required this.nameController,
    required this.brandController,
    required this.modelController,
    required this.yearController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextFormField(
          controller: nameController,
          label: 'Car Name',
          hint: 'e.g., "My Awesome Sedan"',
          iconPath: 'assets/svg/file-description.svg',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextFormField(
                controller: brandController,
                label: 'Brand',
                hint: 'e.g., Toyota',
                iconPath: 'assets/svg/users.svg',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFormField(
                controller: modelController,
                label: 'Model',
                hint: 'e.g., Camry',
                iconPath: 'assets/svg/car2.svg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextFormField(
          controller: yearController,
          label: 'Year',
          hint: 'e.g., 2023',
          iconPath: 'assets/svg/calendar.svg',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String iconPath,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            color: AppTheme.lightBlue,
          ),
        ),
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
