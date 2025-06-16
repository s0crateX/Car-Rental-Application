import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:car_rental_app/config/theme.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final String iconPath;
  final Color color;
  final Color? iconColor;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.count,
    required this.iconPath,
    this.color = AppTheme.mediumBlue,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6), // Reduced margin
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none, // Allow overflow for decorative elements
            children: [
              // Decorative elements - made smaller and positioned more carefully
              Positioned(
                right: -15, // Adjusted position
                top: -15,   // Adjusted position
                child: Container(
                  width: 60,  // Reduced size
                  height: 60, // Reduced size
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16.0), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon with background - made smaller
                    Container(
                      padding: const EdgeInsets.all(8), // Reduced padding
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10), // Slightly smaller radius
                      ),
                      child: SvgPicture.asset(
                        iconPath,
                        width: 20,  // Reduced size
                        height: 20, // Reduced size
                        colorFilter: ColorFilter.mode(
                          iconColor ?? Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12), // Reduced spacing
                    // Count - adjusted text size
                    Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    // Title - smaller text
                    Text(
                      title.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3, // Reduced letter spacing
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
