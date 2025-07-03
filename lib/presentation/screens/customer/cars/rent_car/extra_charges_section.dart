import 'package:flutter/material.dart';
import 'package:car_rental_app/shared/utils/price_utils.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/shared/models/Final%20Model/Firebase_car_model.dart';

class ExtraChargesSection extends StatefulWidget {
  final CarModel car;
  final Map<String, bool> selectedExtras;
  final ValueChanged<String> onToggle;
  final String? title;
  final String? subtitle;

  const ExtraChargesSection({
    super.key,
    required this.car,
    required this.selectedExtras,
    required this.onToggle,
    this.title = 'Extra Charges (Optional)',
    this.subtitle = 'Select additional services for your rental',
  });

  @override
  State<ExtraChargesSection> createState() => _ExtraChargesSectionState();
}

class _ExtraChargesSectionState extends State<ExtraChargesSection>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late AnimationController _countAnimationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _countAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _countAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _countAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _countAnimationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // Convert Firebase extraCharges to Map<String, double> for calculations
  Map<String, double> get _extraChargesMap {
    final Map<String, double> result = {};
    for (final charge in widget.car.extraCharges) {
      if (charge.containsKey('name') && charge.containsKey('price')) {
        final name = charge['name']?.toString() ?? '';
        final price =
            double.tryParse(charge['price']?.toString() ?? '0') ?? 0.0;
        if (name.isNotEmpty) {
          result[name] = price;
        }
      }
    }
    return result;
  }

  int get _selectedCount {
    return widget.selectedExtras.values.where((selected) => selected).length;
  }

  double get _totalSelectedPrice {
    double total = 0;
    final chargesMap = _extraChargesMap;
    widget.selectedExtras.forEach((key, selected) {
      if (selected && chargesMap.containsKey(key)) {
        total += chargesMap[key]!;
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extraChargesMap = _extraChargesMap;
    final hasValidExtraCharges = extraChargesMap.isNotEmpty;

    // Trigger count animation when selection changes
    if (_selectedCount > 0) {
      _countAnimationController.forward();
    } else {
      _countAnimationController.reverse();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.cardColor,
        child: Column(
          children: [
            // Header Section
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleDropdown,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.mediumBlue.withOpacity(0.05),
                        AppTheme.lightBlue.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon with subtle animation
                      AnimatedBuilder(
                        animation: _expandAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_expandAnimation.value * 0.1),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.mediumBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                color: AppTheme.mediumBlue,
                                size: 22,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      // Title and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title ?? '',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.paleBlue,
                                fontSize: 17,
                              ),
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.subtitle!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.paleBlue.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Selected count badge with animation
                      if (_selectedCount > 0)
                        AnimatedBuilder(
                          animation: _countAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _countAnimation.value,
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.mediumBlue,
                                      AppTheme.lightBlue,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.mediumBlue.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$_selectedCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      // Arrow with rotation animation
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value * 3.14159,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: AppTheme.mediumBlue,
                              size: 26,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Content Section
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    // Divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.paleBlue.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // No extras message
                    if (!hasValidExtraCharges)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.paleBlue.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.paleBlue.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.paleBlue.withOpacity(0.5),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No extra charges available for this vehicle.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.paleBlue.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Extras list
                    if (hasValidExtraCharges)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: extraChargesMap.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final entry = extraChargesMap.entries.elementAt(
                            index,
                          );
                          final isSelected =
                              widget.selectedExtras[entry.key] ?? false;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppTheme.mediumBlue.withOpacity(0.08)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppTheme.mediumBlue.withOpacity(0.2)
                                        : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => widget.onToggle(entry.key),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Custom checkbox
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? AppTheme.mediumBlue
                                                  : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? AppTheme.mediumBlue
                                                    : AppTheme.paleBlue
                                                        .withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child:
                                            isSelected
                                                ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
                                                )
                                                : null,
                                      ),
                                      const SizedBox(width: 16),
                                      // Service name
                                      Expanded(
                                        child: Text(
                                          entry.key,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: AppTheme.paleBlue,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                fontSize: 15,
                                              ),
                                        ),
                                      ),
                                      // Price
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? AppTheme.lightBlue
                                                      .withOpacity(0.1)
                                                  : AppTheme.paleBlue
                                                      .withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '+${PriceUtils.formatPrice(entry.value)}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color:
                                                    isSelected
                                                        ? AppTheme.mediumBlue
                                                        : AppTheme.paleBlue
                                                            .withOpacity(0.7),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    // Total section
                    if (_selectedCount > 0) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.mediumBlue.withOpacity(0.08),
                              AppTheme.lightBlue.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.mediumBlue.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Extra Charges',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.paleBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              PriceUtils.formatPrice(_totalSelectedPrice),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.mediumBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
