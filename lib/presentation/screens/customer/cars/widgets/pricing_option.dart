import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class PricingOption extends StatelessWidget {
  final String period;
  final double price;
  final double? originalPrice;
  final double? discount;
  final String currency;
  final bool isRecommended;
  final VoidCallback? onTap;

  const PricingOption({
    super.key, 
    required this.period, 
    required this.price, 
    this.originalPrice,
    this.discount,
    this.currency = 'PHP',
    this.isRecommended = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        margin: const EdgeInsets.symmetric(vertical: 1.0),
        decoration: BoxDecoration(
          color: isRecommended 
              ? AppTheme.darkNavy.withOpacity(0.15) 
              : Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: isRecommended 
              ? Border.all(color: Theme.of(context).primaryColor, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  period,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isRecommended ? FontWeight.w600 : FontWeight.normal,
                    color: isRecommended ? Theme.of(context).primaryColor : null,
                  ),
                ),
                if (discount != null && discount! > 0) ...[  
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${discount!.toStringAsFixed(0)}% OFF',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (isRecommended && (discount == null || discount! == 0)) ...[  
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Best Value',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            _buildPriceWidget(context, price, currency, originalPrice),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPriceWidget(BuildContext context, double price, String currency, double? originalPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Show original price with strikethrough if there's a discount
        if (originalPrice != null && originalPrice > price) ...[
          Row(
            children: [
              if (currency == 'PHP')
                SvgPicture.asset(
                  'assets/svg/peso.svg',
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                )
              else
                Text(
                  _getCurrencySymbol(currency),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              const SizedBox(width: 2),
              Text(
                _formatPrice(originalPrice),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
        ],
        // Current/discounted price
        Row(
          children: [
            if (currency == 'PHP')
              SvgPicture.asset(
                'assets/svg/peso.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor,
                  BlendMode.srcIn,
                ),
              )
            else
              Text(
                _getCurrencySymbol(currency),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(width: 4),
            Text(
              _formatPrice(price),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'PHP':
        return '₱';
      default:
        return currency;
    }
  }
  
  String _formatPrice(double price) {
    // Format with 2 decimal places if there are decimal values, otherwise as integer
    if (price == price.roundToDouble()) {
      return price.toInt().toString();
    } else {
      return price.toStringAsFixed(2);
    }
  }
}
