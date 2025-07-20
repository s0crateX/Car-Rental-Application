import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class ExtraChargeItem extends StatelessWidget {
  final String title;
  final double amount;
  final String? unit;

  const ExtraChargeItem({
    super.key, 
    required this.title, 
    required this.amount,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title, 
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildPriceWidget(context),
        ],
      ),
    );
  }
  
  Widget _buildPriceWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.mediumBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/svg/peso.svg',
            width: 12,
            height: 12,
            colorFilter: ColorFilter.mode(
              AppTheme.mediumBlue,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${amount.toStringAsFixed(2)}${unit != null ? ' $unit' : ''}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mediumBlue,
                ),
          ),
        ],
      ),
    );
  }
}
