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
      style: TextStyle(
        color: AppTheme.white,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'General Sans',
        letterSpacing: 0.25,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'e.g. 500',
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
