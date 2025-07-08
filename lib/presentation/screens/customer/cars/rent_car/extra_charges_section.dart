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
    this.title = 'Extra Charges',
    this.subtitle,
  });

  @override
  State<ExtraChargesSection> createState() => _ExtraChargesSectionState();
}

class _ExtraChargesSectionState extends State<ExtraChargesSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  Map<String, double> get _extraChargesMap {
    final Map<String, double> result = {};
    for (final charge in widget.car.extraCharges) {
      if (charge.containsKey('name') && charge.containsKey('amount')) {
        final name = charge['name']?.toString() ?? '';
        final price =
            double.tryParse(charge['amount']?.toString() ?? '0') ?? 0.0;
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.cardColor,
        border: Border.all(color: AppTheme.paleBlue.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          // Compact Header
          InkWell(
            onTap: _toggleDropdown,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.mediumBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title ?? 'Extra Charges',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.paleBlue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (_selectedCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.mediumBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_selectedCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.mediumBlue,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  // Divider
                  Container(
                    height: 1,
                    color: AppTheme.paleBlue.withOpacity(0.1),
                  ),
                  const SizedBox(height: 12),
                  // No extras message
                  if (!hasValidExtraCharges)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No extra charges available',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.paleBlue.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  // Compact extras list
                  if (hasValidExtraCharges)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: extraChargesMap.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final entry = extraChargesMap.entries.elementAt(index);
                        final isSelected =
                            widget.selectedExtras[entry.key] ?? false;

                        return InkWell(
                          onTap: () => widget.onToggle(entry.key),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppTheme.mediumBlue.withOpacity(0.08)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  isSelected
                                      ? Border.all(
                                        color: AppTheme.mediumBlue.withOpacity(
                                          0.2,
                                        ),
                                        width: 1,
                                      )
                                      : null,
                            ),
                            child: Row(
                              children: [
                                // Compact checkbox
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? AppTheme.mediumBlue
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? AppTheme.mediumBlue
                                              : AppTheme.paleBlue.withOpacity(
                                                0.3,
                                              ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12,
                                          )
                                          : null,
                                ),
                                const SizedBox(width: 12),
                                // Service name
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.paleBlue,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                // Compact price
                                Text(
                                  '+${PriceUtils.formatPrice(entry.value)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        isSelected
                                            ? AppTheme.mediumBlue
                                            : AppTheme.paleBlue.withOpacity(
                                              0.7,
                                            ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  // Compact total section
                  if (_selectedCount > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.mediumBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Extra Charges',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.paleBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            PriceUtils.formatPrice(_totalSelectedPrice),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mediumBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
    );
  }
}
