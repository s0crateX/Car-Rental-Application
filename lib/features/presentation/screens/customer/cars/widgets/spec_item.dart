import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../config/theme.dart';

class SpecItem extends StatelessWidget {
  final String svgAssetPath;
  final String text;

  const SpecItem({Key? key, required this.svgAssetPath, required this.text})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.mediumBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(
            svgAssetPath,
            width: 28,
            height: 28,
            colorFilter: ColorFilter.mode(AppTheme.mediumBlue, BlendMode.srcIn),
          ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
