import 'package:flutter/material.dart';
import 'package:car_rental_app/shared/models/Final%20Model/Firebase_car_model.dart';
import 'package:car_rental_app/shared/utils/price_utils.dart';
import 'package:car_rental_app/config/theme.dart';

class PaymentBreakdownSection extends StatefulWidget {
  final CarModel car;
  final String selectedPeriod;
  final Map<String, bool> selectedExtras;

  const PaymentBreakdownSection({
    super.key,
    required this.car,
    required this.selectedPeriod,
    required this.selectedExtras,
  });

  @override
  State<PaymentBreakdownSection> createState() =>
      _PaymentBreakdownSectionState();
}

class _PaymentBreakdownSectionState extends State<PaymentBreakdownSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rentalPrice = _getRentalPrice();
    final extraChargesMap = _getExtraChargesMap();
    final selectedExtraTotal = _getSelectedExtraTotal(extraChargesMap);
    final total = rentalPrice + selectedExtraTotal;
    final hasExtras = selectedExtraTotal > 0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [AppTheme.navy, AppTheme.darkNavy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.mediumBlue.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: AppTheme.mediumBlue.withOpacity(0.13),
                  width: 1.2,
                ),
              ),
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.mediumBlue,
                                  AppTheme.lightBlue,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.mediumBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.receipt_long,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Breakdown',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.paleBlue,
                                        fontSize: 20,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Detailed cost summary',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.paleBlue.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Rental Details Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.navy.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.mediumBlue.withOpacity(0.16),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              'Rental Period',
                              _getPeriodDisplayText(),
                              icon: Icons.schedule,
                              iconColor: AppTheme.mediumBlue,
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              'Rental Rate',
                              PriceUtils.formatPrice(rentalPrice),
                              icon: Icons.directions_car,
                              iconColor: AppTheme.lightBlue,
                              isPrice: true,
                            ),
                          ],
                        ),
                      ),

                      // Extra Charges Section
                      if (hasExtras) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.navy.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.lightBlue.withOpacity(0.13),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: AppTheme.mediumBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Additional Services',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.paleBlue,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...extraChargesMap.entries
                                  .where(
                                    (entry) =>
                                        widget.selectedExtras[entry.key] ==
                                        true,
                                  )
                                  .map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _buildExtraRow(
                                        entry.key,
                                        PriceUtils.formatPrice(entry.value),
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ],

                      // Divider
                      const SizedBox(height: 24),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          color: AppTheme.mediumBlue.withOpacity(0.07),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Total Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.mediumBlue.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.mediumBlue.withOpacity(0.22),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Final payment due',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.paleBlue.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.mediumBlue,
                                    AppTheme.lightBlue,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.mediumBlue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                PriceUtils.formatPrice(total),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    required IconData icon,
    required Color iconColor,
    bool isPrice = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.paleBlue.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.paleBlue,
            fontWeight: FontWeight.w600,
            fontSize: isPrice ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildExtraRow(String label, String value) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.mediumBlue.withOpacity(0.6),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.paleBlue.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.mediumBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Map<String, double> _getExtraChargesMap() {
    final Map<String, double> extraChargesMap = {};
    for (final charge in widget.car.extraCharges) {
      if (charge.containsKey('name') && charge.containsKey('price')) {
        final name = charge['name'] as String;
        final price = double.tryParse(charge['price'].toString()) ?? 0.0;
        extraChargesMap[name] = price;
      }
    }
    return extraChargesMap;
  }

  double _getSelectedExtraTotal(Map<String, double> extraChargesMap) {
    return extraChargesMap.entries
        .where(
          (entry) =>
              widget.selectedExtras[entry.key] == true &&
              entry.key != '6 Hour Rate' &&
              entry.key != '12 Hour Rate',
        )
        .fold(0.0, (sum, entry) => sum + entry.value);
  }

  double _getRentalPrice() {
    return PriceUtils.calculateRentalPrice(
      car: widget.car,
      period: widget.selectedPeriod,
    );
  }

  String _getPeriodDisplayText() {
    // Handle predefined periods first
    switch (widget.selectedPeriod) {
      case '6h':
        return '6 Hours';
      case '12h':
        return '12 Hours';
      case '1d':
        return '1 Day';
      case '1w':
        return '1 Week';
      case '1m':
        return '1 Month';
    }

    // Handle custom periods by parsing the string
    // Expected format: 'Nd' for N days, 'Nh' for N hours
    final RegExp daysRegExp = RegExp(r'(\d+)d');
    final RegExp hoursRegExp = RegExp(r'(\d+)h');

    // Check for custom days
    final daysMatch = daysRegExp.firstMatch(widget.selectedPeriod);
    if (daysMatch != null && daysMatch.groupCount >= 1) {
      final days = int.tryParse(daysMatch.group(1)!);
      if (days != null) {
        return '$days ${days == 1 ? 'Day' : 'Days'}';
      }
    }

    // Check for custom hours
    final hoursMatch = hoursRegExp.firstMatch(widget.selectedPeriod);
    if (hoursMatch != null && hoursMatch.groupCount >= 1) {
      final hours = int.tryParse(hoursMatch.group(1)!);
      if (hours != null) {
        return '$hours ${hours == 1 ? 'Hour' : 'Hours'}';
      }
    }

    // Fallback
    return '1 Day';
  }
}
