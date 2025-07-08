import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class PricingSectionWidget extends StatelessWidget {
  final TextEditingController hourlyRateController;

  const PricingSectionWidget({super.key, required this.hourlyRateController});

  @override
  Widget build(BuildContext context) {
    return _buildPriceField(
      controller: hourlyRateController,
      label: 'Hourly Rate',
      icon: 'assets/svg/peso.svg',
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String label,
    required String icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
        errorStyle: const TextStyle(color: Colors.orange),
        labelStyle: TextStyle(color: AppTheme.lightBlue.withOpacity(0.8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a price';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }
}
