import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../shared/models/Final Model/Firebase_car_model.dart';
import '../../../../../config/theme.dart';

class RentalDurationSelector extends StatefulWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final CarModel car;

  const RentalDurationSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.car,
  });

  @override
  State<RentalDurationSelector> createState() => _RentalDurationSelectorState();
}

class _RentalDurationSelectorState extends State<RentalDurationSelector>
    with TickerProviderStateMixin {
  final TextEditingController _daysController = TextEditingController();
  bool _isCustomDuration = false;
  String _customPeriod = '';
  String _errorText = '';
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Pricing configuration
  static const Map<String, double> _priceMultipliers = {
    '6h': 0.35,
    '12h': 0.6,
    '1d': 1.0,
    '1w': 6.3,
    '1m': 24.0,
  };

  static const Map<String, String> _durationLabels = {
    '6h': '6 Hours',
    '12h': '12 Hours',
    '1d': '1 Day',
    '1w': '1 Week',
    '1m': '1 Month',
  };

  static const Map<String, IconData> _durationIcons = {
    '6h': Icons.access_time,
    '12h': Icons.access_time_filled,
    '1d': Icons.today,
    '1w': Icons.date_range,
    '1m': Icons.calendar_month,
  };

  @override
  void initState() {
    super.initState();
    _daysController.text = '0';

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    if (widget.selectedPeriod.isNotEmpty &&
        !_priceMultipliers.containsKey(widget.selectedPeriod)) {
      _parseCustomPeriod(widget.selectedPeriod);
    }
  }

  @override
  void dispose() {
    _daysController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _parseCustomPeriod(String period) {
    final customPeriodRegex = RegExp(r'(\d+)d');
    final match = customPeriodRegex.firstMatch(period);

    if (match != null) {
      final days = int.parse(match.group(1) ?? '0');

      setState(() {
        _isCustomDuration = true;
        _customPeriod = period;
        _daysController.text = days.toString();
      });
      _slideController.forward();
      _fadeController.forward();
    }
  }

  void _updateCustomDuration() {
    final int days = int.tryParse(_daysController.text) ?? 0;

    if (days == 0) {
      setState(() {
        _errorText = 'Minimum rental is 1 day';
        _customPeriod = '';
      });
      return;
    }

    if (days < 0) {
      setState(() {
        _errorText = 'Days must be a positive number';
        _customPeriod = '';
      });
      return;
    }

    setState(() {
      _errorText = '';
      _customPeriod = '${days}d';
      _isCustomDuration = true;
    });

    widget.onPeriodChanged(_customPeriod);
  }

  double _calculateRawPrice(String period) {
    double basePrice = double.tryParse(widget.car.price.toString()) ?? 0;

    if (_priceMultipliers.containsKey(period)) {
      return basePrice * _priceMultipliers[period]!;
    }

    final customPeriodRegex = RegExp(r'(\d+)d');
    final match = customPeriodRegex.firstMatch(period);

    if (match != null) {
      final days = int.parse(match.group(1) ?? '0');
      double totalPrice = 0;

      double dailyRate = basePrice * (_priceMultipliers['1d'] ?? 1.0);

      if (days > 0) {
        totalPrice = days * dailyRate;
      }

      if (days >= 30) {
        totalPrice *= 0.8;
      } else if (days >= 7) {
        totalPrice *= 0.9;
      } else if (days >= 3) {
        totalPrice *= 0.95;
      }

      return totalPrice;
    }

    return basePrice;
  }

  String _getFormattedPrice(String period) {
    return _calculateRawPrice(period).toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.navy, AppTheme.darkNavy],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.mediumBlue, AppTheme.lightBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.schedule, color: AppTheme.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rental Duration',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.mediumBlue,
                      ),
                    ),
                    Text(
                      'Choose your preferred rental period',
                      style: TextStyle(fontSize: 14, color: AppTheme.paleBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Duration Options Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              final childAspectRatio = constraints.maxWidth > 600 ? 1.4 : 1.2;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: childAspectRatio,
                children: [
                  ..._priceMultipliers.keys.map(
                    (period) => _buildDurationCard(
                      context,
                      period,
                      _durationLabels[period]!,
                      _durationIcons[period]!,
                    ),
                  ),
                  _buildCustomDurationCard(context),
                ],
              );
            },
          ),

          // Custom Duration Inputs
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Transform.translate(
                  offset: Offset(0, (1 - _slideAnimation.value) * 50),
                  child: Opacity(
                    opacity: _slideAnimation.value,
                    child:
                        _isCustomDuration
                            ? _buildCustomInputs(context)
                            : const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),

          // Price Breakdown
          if (_isCustomDuration &&
              _customPeriod.isNotEmpty &&
              _errorText.isEmpty) ...[
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: _buildPriceBreakdown(context),
                );
              },
            ),
          ],

          const SizedBox(height: 20),
          _buildDiscountInfo(context),
        ],
      ),
    );
  }

  Widget _buildDurationCard(
    BuildContext context,
    String period,
    String label,
    IconData icon,
  ) {
    final bool isSelected =
        widget.selectedPeriod == period && !_isCustomDuration;
    
    // Track original price from Firebase car model
    String originalPrice = '';
    
    // Get price based on period
    switch (period) {
      case '6h':
        originalPrice = widget.car.price6h;
        break;
      case '12h':
        originalPrice = widget.car.price12h;
        break;
      case '1d':
        originalPrice = widget.car.price1d;
        break;
      case '1w':
        originalPrice = widget.car.price1w;
        break;
      case '1m':
        originalPrice = widget.car.price1m;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _isCustomDuration = false;
              _customPeriod = '';
              _errorText = '';
            });
            _slideController.reverse();
            _fadeController.reverse();
            widget.onPeriodChanged(period);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient:
                  isSelected
                      ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.mediumBlue, AppTheme.lightBlue],
                      )
                      : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.navy, AppTheme.darkNavy],
                      ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected
                        ? AppTheme.mediumBlue
                        : AppTheme.lightBlue.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: AppTheme.mediumBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.white.withOpacity(0.2)
                            : AppTheme.mediumBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppTheme.mediumBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 1,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '₱${double.tryParse(originalPrice)?.toStringAsFixed(0) ?? originalPrice}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.mediumBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDurationCard(BuildContext context) {
    final bool isSelected = _isCustomDuration;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _isCustomDuration = true;
              if (_daysController.text == '0') {
                _daysController.text = '1';
                _updateCustomDuration();
              }
            });
            _slideController.forward();
            _fadeController.forward();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient:
                  isSelected
                      ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.mediumBlue, AppTheme.lightBlue],
                      )
                      : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.navy, AppTheme.darkNavy],
                      ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected
                        ? AppTheme.mediumBlue
                        : AppTheme.lightBlue.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: AppTheme.mediumBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                      : [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.white.withOpacity(0.2)
                            : AppTheme.mediumBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: isSelected ? Colors.white : AppTheme.mediumBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Custom',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                if (isSelected &&
                    _customPeriod.isNotEmpty &&
                    _errorText.isEmpty)
                  Text(
                    '₱${_getFormattedPrice(_customPeriod)}',
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    'Set your own',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.mediumBlue,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomInputs(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_calendar, color: AppTheme.mediumBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Custom Duration',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.mediumBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCustomTextField(
            controller: _daysController,
            label: 'Days',
            icon: Icons.calendar_today,
            onChanged: (_) => _updateCustomDuration(),
          ),
          if (_errorText.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade900.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade400),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorText,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppTheme.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.mediumBlue),
        filled: true,
        fillColor: AppTheme.navy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.mediumBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(BuildContext context) {
    final customPeriodRegex = RegExp(r'(\d+)d');
    final match = customPeriodRegex.firstMatch(_customPeriod);

    if (match == null) return Container();

    final days = int.parse(match.group(1) ?? '0');
    final basePrice = double.tryParse(widget.car.price.toString()) ?? 0;
    
    final dailyRate = basePrice * (_priceMultipliers['1d'] ?? 1.0);
    final daysPrice = days * dailyRate;
    final hours = 0; // Custom duration doesn't support hours currently
    final hoursPrice = 0.0;
    final subtotal = daysPrice + hoursPrice;

    double discountAmount = 0.0;
    String discountLabel = '';
    double totalPrice = subtotal;

    if (days >= 30) {
      discountAmount = subtotal * 0.2;
      discountLabel = '20% Bulk Discount';
      totalPrice = subtotal - discountAmount;
    } else if (days >= 7) {
      discountAmount = subtotal * 0.1;
      discountLabel = '10% Bulk Discount';
      totalPrice = subtotal - discountAmount;
    } else if (days >= 3) {
      discountAmount = subtotal * 0.05;
      discountLabel = '5% Bulk Discount';
      totalPrice = subtotal - discountAmount;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.navy, AppTheme.darkNavy],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.mediumBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: AppTheme.mediumBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Price Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.mediumBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (days > 0)
            _buildBreakdownRow(
              '${days} ${days == 1 ? 'Day' : 'Days'}',
              '₱${daysPrice.toStringAsFixed(0)}',
              Icons.calendar_today,
            ),

          if (hours > 0)
            _buildBreakdownRow(
              '${hours} ${hours == 1 ? 'Hour' : 'Hours'}',
              '₱${hoursPrice.toStringAsFixed(0)}',
              Icons.access_time,
            ),

          if (days > 0 && hours > 0)
            _buildBreakdownRow(
              'Subtotal',
              '₱${subtotal.toStringAsFixed(0)}',
              Icons.calculate,
            ),

          if (discountAmount > 0)
            _buildBreakdownRow(
              discountLabel,
              '- ₱${discountAmount.toStringAsFixed(0)}',
              Icons.local_offer,
              valueColor: Colors.green,
            ),

          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.shade400,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          _buildBreakdownRow(
            'Total Amount',
            '₱${totalPrice.toStringAsFixed(0)}',
            Icons.payments,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value,
    IconData icon, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isTotal ? AppTheme.mediumBlue : AppTheme.lightBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? AppTheme.mediumBlue : AppTheme.white,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 18 : 14,
              color:
                  valueColor ??
                  (isTotal ? AppTheme.mediumBlue : AppTheme.white),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.mediumBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.mediumBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bulk discounts: 3+ days (5% off) • 7+ days (10% off) • 30+ days (20% off)',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.paleBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
