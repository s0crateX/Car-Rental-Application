import 'package:flutter/material.dart';
import 'package:car_rental_app/shared/models/Final Model/Firebase_car_model.dart';

class PaymentSummarySection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final CarModel car;
  final Map<String, bool> selectedExtras;
  final double deliveryCharge;

  const PaymentSummarySection({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.car,
    required this.selectedExtras,
    required this.deliveryCharge,
  });

  // Helper method to build section titles with consistent styling
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (startDate == null ||
        endDate == null ||
        endDate!.isBefore(startDate!)) {
      return const SizedBox.shrink(); // Don't show if dates are invalid
    }

    final duration = endDate!.difference(startDate!);
    final totalHours = duration.inHours > 0 ? duration.inHours : 0;
    final totalDays = duration.inDays;

    final carRentalCost = totalHours * car.hourlyRate;
    final downPayment = carRentalCost * 0.5; // 50% of car rental cost

    double totalExtraCharges = 0;
    selectedExtras.forEach((name, isSelected) {
      if (isSelected) {
        final chargeData = car.extraCharges.firstWhere(
          (c) => c['name'] == name,
          orElse: () => {'name': name, 'amount': '0.0'},
        );
        final price =
            double.tryParse(chargeData['amount']?.toString() ?? '0') ?? 0.0;
        totalExtraCharges += price;
      }
    });

    final double grandTotal =
        carRentalCost + totalExtraCharges + deliveryCharge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Payment Summary'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Car Rental (${totalDays}d ${totalHours % 24}h)'),
                  Text('₱${carRentalCost.toStringAsFixed(2)}'),
                ],
              ),
              if (totalExtraCharges > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Extra Charges'),
                    Text('₱${totalExtraCharges.toStringAsFixed(2)}'),
                  ],
                ),
              ],
              if (deliveryCharge > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delivery Charge'),
                    Text('₱${deliveryCharge.toStringAsFixed(2)}'),
                  ],
                ),
              ],
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Payment',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '₱${grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Down Payment (50%)'),
                  Text('₱${downPayment.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'A 50% down payment is required to confirm the booking, excluding extra charges. The remaining balance, along with any applicable extra charges, must be paid upon return of the vehicle. Additional fees may apply for late returns or based on the condition and usage of the vehicle.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
