import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class SpecificationsSectionWidget extends StatelessWidget {
  final String transmissionType;
  final String fuelType;
  final TextEditingController seatsController;
  final ValueChanged<String?> onTransmissionChanged;
  final ValueChanged<String?> onFuelChanged;
  
  const SpecificationsSectionWidget({
    super.key,
    required this.transmissionType,
    required this.fuelType,
    required this.seatsController,
    required this.onTransmissionChanged,
    required this.onFuelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First row: Transmission and Fuel Type
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'Transmission',
                value: transmissionType,
                items: const ['Automatic', 'Manual'],
                icon: '', // Icon is now determined dynamically
                onChanged: onTransmissionChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown(
                label: 'Fuel Type',
                value: fuelType,
                items: const ['Gasoline', 'Unleaded', 'Diesel', 'Electric', 'Hybrid'],
                icon: 'assets/svg/gas-station.svg',
                onChanged: onFuelChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Second row: Seats (centered)
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextFormField(
                controller: seatsController,
                label: 'Number of Seats',
                hint: 'e.g. 5',
                icon: 'assets/svg/seats.svg',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of seats';
                  }
                  final number = int.tryParse(value);
                  if (number == null) {
                    return 'Please enter a valid number';
                  }
                  if (number < 1 || number > 50) {
                    return 'Please enter a number between 1-50';
                  }
                  return null;
                },
              ),
            ),
            const Expanded(flex: 1, child: SizedBox()), // Spacer to center the seats field
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required String icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: TextStyle(
        color: AppTheme.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'General Sans',
        letterSpacing: 0.25,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppTheme.lightBlue.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w300,
          fontFamily: 'General Sans',
          letterSpacing: 0.25,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            _getIconForValue(label, value),
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              AppTheme.lightBlue.withOpacity(0.8),
              BlendMode.srcIn,
            ),
          ),
        ),
        filled: true,
        fillColor: AppTheme.darkNavy,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
      ),
      dropdownColor: AppTheme.darkNavy,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: AppTheme.lightBlue.withOpacity(0.8),
        size: 24,
      ),
      isExpanded: true, // Fix overflow issue
      items: items
          .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'General Sans',
                    letterSpacing: 0.25,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  String _getIconForValue(String label, String value) {
    if (label == 'Transmission') {
      switch (value) {
        case 'Automatic':
          return 'assets/svg/automatic-gearbox.svg';
        case 'Manual':
          return 'assets/svg/manual-gearbox.svg';
        default:
          return 'assets/svg/settings.svg';
      }
    }
    return 'assets/svg/gas-station.svg'; // Default for fuel type
  }



  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: AppTheme.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'General Sans',
        letterSpacing: 0.25,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
        prefixIcon: Container(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              AppTheme.lightBlue.withOpacity(0.8),
              BlendMode.srcIn,
            ),
          ),
        ),
        filled: true,
        fillColor: AppTheme.darkNavy,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
        errorStyle: TextStyle(
          color: AppTheme.red,
          fontSize: 12,
          fontWeight: FontWeight.w300,
          fontFamily: 'General Sans',
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
