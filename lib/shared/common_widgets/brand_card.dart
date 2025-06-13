import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/car_brand_model.dart';

class BrandCard extends StatelessWidget {
  final CarBrandModel brand;
  final VoidCallback? onTap;

  const BrandCard({super.key, required this.brand, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SvgPicture.asset(brand.logo, width: 32, height: 32),
          ),
          const SizedBox(height: 4),
          Text(
            brand.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
