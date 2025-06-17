import 'package:flutter/material.dart';
import 'package:car_rental_app/shared/models/car_model.dart';
import 'package:car_rental_app/shared/utils/price_utils.dart';

class PaymentBreakdownSection extends StatelessWidget {
  final CarModel car;
  final int rentalDays;
  final Map<String, bool> selectedExtras;

  const PaymentBreakdownSection({
    super.key,
    required this.car,
    required this.rentalDays,
    required this.selectedExtras,
  });

  @override
  Widget build(BuildContext context) {
    final double dailyRate = car.price;
    final double rentalSubtotal = dailyRate * rentalDays;
    final extraCharges = car.extraCharges;
    final selectedExtraTotal = extraCharges.entries
        .where((entry) => selectedExtras[entry.key] == true)
        .fold(0.0, (sum, entry) => sum + entry.value);
    final double total = rentalSubtotal + selectedExtraTotal;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _row('Daily Rate', PriceUtils.formatPrice(dailyRate)),
            _row('Rental Days', rentalDays.toString()),
            _row('Subtotal', PriceUtils.formatPrice(rentalSubtotal)),
            if (selectedExtras.values.any((v) => v)) ...[
              const Divider(),
              ...extraCharges.entries
                  .where((entry) => selectedExtras[entry.key] == true)
                  .map(
                    (entry) =>
                        _row(entry.key, PriceUtils.formatPrice(entry.value)),
                  ),
            ],
            const Divider(),
            _row('Total', PriceUtils.formatPrice(total), isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
          Text(
            value,
            style:
                isTotal ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }
}
