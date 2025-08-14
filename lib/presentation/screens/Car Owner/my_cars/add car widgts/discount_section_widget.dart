import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class DiscountSectionWidget extends StatelessWidget {
  final TextEditingController threeDaysDiscountController;
  final TextEditingController oneWeekDiscountController;
  final TextEditingController oneMonthDiscountController;

  const DiscountSectionWidget({
    super.key,
    required this.threeDaysDiscountController,
    required this.oneWeekDiscountController,
    required this.oneMonthDiscountController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        

        Text(
          'Set percentage discounts for longer rental periods (optional)',
          style: TextStyle(
            color: AppTheme.paleBlue.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            fontFamily: 'General Sans',
            letterSpacing: 0.25,
          ),
        ),
        const SizedBox(height: 24),

        // Discount fields
        _buildDiscountField(
          controller: threeDaysDiscountController,
          label: 'Short-term Discount (%)',
          subtitle: 'Applied for 3-6 day rentals',
        ),
        const SizedBox(height: 20),
        
        _buildDiscountField(
          controller: oneWeekDiscountController,
          label: 'Weekly Discount (%)',
          subtitle: 'Applied for 7-29 day rentals',
        ),
        const SizedBox(height: 20),
        
        _buildDiscountField(
          controller: oneMonthDiscountController,
          label: 'Monthly Discount (%)',
          subtitle: 'Applied for 30+ day rentals',
        ),
        const SizedBox(height: 16),

        // Info container
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.darkNavy.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.lightBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Discount Algorithm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w500,
                    ) ?? TextStyle(
                      color: AppTheme.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'General Sans',
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoTip('System applies the highest applicable discount based on rental duration'),
              _buildInfoTip('Example: 14-day rental gets Weekly discount (not Short-term)'),
              _buildInfoTip('Recommended: 5% short-term, 10% weekly, 15% monthly'),
              _buildInfoTip('Leave blank or enter 0 for no discount on that tier'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountField({
    required TextEditingController controller,
    required String label,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'General Sans',
            letterSpacing: 0.25,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: 'e.g. 10',
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
              child: Icon(
                Icons.percent,
                color: AppTheme.lightBlue.withOpacity(0.8),
                size: 20,
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
            if (value != null && value.isNotEmpty) {
              final discount = double.tryParse(value);
              if (discount == null) {
                return 'Please enter a valid number';
              }
              if (discount < 0 || discount > 50) {
                return 'Discount must be between 0% and 50%';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.paleBlue.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w300,
            fontFamily: 'General Sans',
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.lightBlue.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: AppTheme.paleBlue.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w300,
                fontFamily: 'General Sans',
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}