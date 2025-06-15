import 'package:flutter/material.dart';
import 'package:car_rental_app/shared/utils/price_utils.dart';
import 'package:car_rental_app/config/theme.dart';

class ExtraChargesSection extends StatefulWidget {
  final Map<String, double> extraCharges;
  final Map<String, bool> selectedExtras;
  final ValueChanged<String> onToggle;
  final String? title;
  final String? subtitle;

  const ExtraChargesSection({
    Key? key,
    required this.extraCharges,
    required this.selectedExtras,
    required this.onToggle,
    this.title = 'Extra Charges (Optional)',
    this.subtitle = 'Select additional services for your rental',
  }) : super(key: key);

  @override
  State<ExtraChargesSection> createState() => _ExtraChargesSectionState();
}

class _ExtraChargesSectionState extends State<ExtraChargesSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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

  int get _selectedCount {
    return widget.selectedExtras.values.where((selected) => selected).length;
  }

  double get _totalSelectedPrice {
    double total = 0;
    widget.selectedExtras.forEach((key, selected) {
      if (selected && widget.extraCharges.containsKey(key)) {
        total += widget.extraCharges[key]!;
      }
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: Column(
        children: [
          InkWell(
            onTap: _toggleDropdown,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.mediumBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title ?? '',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.paleBlue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (_selectedCount > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.mediumBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$_selectedCount',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * 3.14159,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppTheme.mediumBlue,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.extraCharges.length,
                    itemBuilder: (context, index) {
                      final entry = widget.extraCharges.entries.elementAt(index);
                      final isSelected = widget.selectedExtras[entry.key] ?? false;
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (_) => widget.onToggle(entry.key),
                          activeColor: AppTheme.mediumBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        title: Text(
                          entry.key,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.paleBlue,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: Text(
                          '+${PriceUtils.formatPrice(entry.value)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected ? AppTheme.lightBlue : AppTheme.paleBlue.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => widget.onToggle(entry.key),
                      );
                    },
                  ),
                  if (_selectedCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Total: ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            PriceUtils.formatPrice(_totalSelectedPrice),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mediumBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtraChargeItem extends StatefulWidget {
  final String title;
  final double price;
  final bool isSelected;
  final VoidCallback onToggle;

  const _ExtraChargeItem({
    required this.title,
    required this.price,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  State<_ExtraChargeItem> createState() => _ExtraChargeItemState();
}

class _ExtraChargeItemState extends State<_ExtraChargeItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _animationController.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _animationController.reverse();
              widget.onToggle();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _animationController.reverse();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    widget.isSelected
                        ? theme.primaryColor.withOpacity(0.1)
                        : theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      widget.isSelected
                          ? theme.primaryColor
                          : theme.dividerColor.withOpacity(0.3),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow:
                    widget.isSelected
                        ? [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                children: [
                  // Custom checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          widget.isSelected
                              ? theme.primaryColor
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color:
                            widget.isSelected
                                ? theme.primaryColor
                                : theme.dividerColor,
                        width: 2,
                      ),
                    ),
                    child:
                        widget.isSelected
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),

                  // Title and price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                widget.isSelected ? theme.primaryColor : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Additional charge',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Price badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          widget.isSelected
                              ? theme.primaryColor
                              : theme.dividerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+${PriceUtils.formatPrice(widget.price)}',
                      style: TextStyle(
                        color:
                            widget.isSelected
                                ? Colors.white
                                : theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Example usage
class ExtraChargesDemo extends StatefulWidget {
  @override
  State<ExtraChargesDemo> createState() => _ExtraChargesDemoState();
}

class _ExtraChargesDemoState extends State<ExtraChargesDemo> {
  final Map<String, double> extraCharges = {
    'GPS Navigation': 5.99,
    'Child Safety Seat': 12.50,
    'Additional Driver': 8.00,
    'Roadside Assistance': 6.99,
    'Full Insurance Coverage': 15.99,
    'Toll Pass': 4.50,
    'Bluetooth Adapter': 3.99,
    'USB Charger': 2.99,
  };

  Map<String, bool> selectedExtras = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Rental Extras')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ExtraChargesSection(
          extraCharges: extraCharges,
          selectedExtras: selectedExtras,
          onToggle: (key) {
            setState(() {
              selectedExtras[key] = !(selectedExtras[key] ?? false);
            });
          },
        ),
      ),
    );
  }
}
