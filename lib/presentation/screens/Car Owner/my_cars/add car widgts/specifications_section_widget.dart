import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class SpecificationsSectionWidget extends StatelessWidget {
  final String transmissionType;
  final String fuelType;
  final TextEditingController seatsController;
  final TextEditingController luggageController;
  final ValueChanged<String?> onTransmissionChanged;
  final ValueChanged<String?> onFuelChanged;
  const SpecificationsSectionWidget({
    super.key,
    required this.transmissionType,
    required this.fuelType,
    required this.seatsController,
    required this.luggageController,
    required this.onTransmissionChanged,
    required this.onFuelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'Transmission',
                value: transmissionType,
                items: const ['Automatic', 'Manual'],
                icon: 'assets/svg/automatic-gearbox.svg',
                onChanged: onTransmissionChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdown(
                label: 'Fuel Type',
                value: fuelType,
                items: const ['Petrol', 'Diesel', 'Electric', 'Hybrid'],
                icon: 'assets/svg/gas-station.svg',
                onChanged: onFuelChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextFormField(
                controller: seatsController,
                label: 'Seats',
                icon: 'assets/svg/seats.svg',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextFormField(
                controller: luggageController,
                label: 'Luggage #',
                icon: 'assets/svg/luggage.svg',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
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
      style: const TextStyle(color: AppTheme.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            icon,
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
      ),
      dropdownColor: AppTheme.navy,
      items: items
          .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(color: AppTheme.white)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppTheme.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            icon,
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
        errorStyle: const TextStyle(color: Colors.orange),
        labelStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.8)),
      ),
    );
  }
}
