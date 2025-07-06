import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/theme.dart';
import '../models/Final Model/car_brand_model.dart';

class BrandCard extends StatefulWidget {
  final CarBrandModel brand;
  final VoidCallback? onTap;
  final bool isSelected;

  const BrandCard({
    super.key,
    required this.brand,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<BrandCard> {
  bool _isHovered = false;
  static const double _scaleFactor = 1.05;
  static const Duration _animationDuration = Duration(milliseconds: 200);

  // Handle brand logo loading with error fallback
  Widget _buildBrandLogo(String logoPath, bool isSelected) {
    return Builder(
      builder: (context) {
        try {
          return SvgPicture.asset(
            logoPath,
            width: 28,
            height: 28,
            colorFilter: isSelected
                ? const ColorFilter.mode(
                    AppTheme.white,
                    BlendMode.srcIn,
                  )
                : null,
            placeholderBuilder: (BuildContext context) => _buildFallbackLogo(isSelected),
          );
        } catch (e) {
          // Return fallback for any exception
          return _buildFallbackLogo(isSelected);
        }
      },
    );
  }

  // Fallback icon when SVG can't be loaded
  Widget _buildFallbackLogo(bool isSelected) {
    return Icon(
      Icons.directions_car_rounded,
      size: 28,
      color: isSelected 
          ? AppTheme.white 
          : Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: TweenAnimationBuilder<double>(
          duration: _animationDuration,
          tween: Tween(begin: 1.0, end: _isHovered ? _scaleFactor : 1.0),
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: _animationDuration,
                    padding: const EdgeInsets.all(
                      12,
                    ), // <-- Adjust padding here to resize the card
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        // --- COLOR COMBINATION: Adjust these for the BrandCard look ---
                        colors:
                            widget.isSelected
                                ? [
                                  AppTheme
                                      .lightBlue, // <-- Selected gradient start
                                  AppTheme
                                      .paleBlue, // <-- Selected gradient end
                                ]
                                : [
                                  AppTheme.white.withOpacity(
                                    0.92,
                                  ), // <-- Unselected gradient start
                                  AppTheme.paleBlue.withOpacity(
                                    0.6,
                                  ), // <-- Unselected gradient end
                                ],
                      ),
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // <-- Adjust border radius here
                      border: Border.all(
                        color:
                            widget.isSelected
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.outline.withOpacity(0.1),
                        width: widget.isSelected ? 1.2 : 0.8,
                      ),
                      boxShadow: [
                        if (widget.isSelected || _isHovered)
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: _buildBrandLogo(widget.brand.logo, widget.isSelected),
                  ),
                  const SizedBox(
                    height: 6,
                  ), // <-- Adjust spacing between logo and text here
                  AnimatedDefaultTextStyle(
                    duration: _animationDuration,
                    style: TextStyle(
                      fontSize: 11, // <-- Adjust font size here
                      fontWeight:
                          FontWeight.w500, // <-- Adjust font weight here
                      color:
                          widget.isSelected
                              ? theme.colorScheme.secondary
                              : theme.colorScheme.onSurface.withOpacity(0.9),
                      letterSpacing: 0.2,
                    ),
                    child: Text(widget.brand.name),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
