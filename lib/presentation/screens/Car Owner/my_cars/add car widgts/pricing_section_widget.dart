import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class PricingSectionWidget extends StatelessWidget {
  final TextEditingController price6hController;
  final TextEditingController price12hController;
  final TextEditingController price1dController;
  final TextEditingController price1wController;
  final TextEditingController price1mController;
  const PricingSectionWidget({
    super.key,
    required this.price6hController,
    required this.price12hController,
    required this.price1dController,
    required this.price1wController,
    required this.price1mController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPriceField(
                controller: price6hController,
                label: '6 Hours',
                icon: 'assets/svg/clock-hour-6.svg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceField(
                controller: price12hController,
                label: '12 Hours',
                icon: 'assets/svg/clock-hour-12.svg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPriceField(
                controller: price1dController,
                label: '1 Day',
                icon: 'assets/svg/calendar.svg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceField(
                controller: price1wController,
                label: '1 Week',
                icon: 'assets/svg/calendar-week.svg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPriceField(
          controller: price1mController,
          label: '1 Month',
          icon: 'assets/svg/calendar-month.svg',
        ),
      ],
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
        prefixText: '₱ ',
        prefixStyle: const TextStyle(
          color: AppTheme.lightBlue,
          fontWeight: FontWeight.w600,
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
