import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../shared/models/booking_model.dart';
import '../../../../../../shared/models/payment_method.dart';

class PaymentSummaryCard extends StatelessWidget {
  final BookingModel booking;
  
  const PaymentSummaryCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '₱');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (booking.paymentMethod != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, size: 18, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Text(
                      'Paid via ',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      booking.paymentMethod!.displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            if (booking.receiptImageUrl != null && booking.receiptImageUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 18, color: Colors.blueGrey),
                        const SizedBox(width: 8),
                        Text('Receipt', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        booking.receiptImageUrl!,
                        height: 100,
                        width: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          height: 100,
                          width: 180,
                          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildPaymentRow(
              'Base Rate',
              currencyFormat.format(booking.totalAmount - _calculateExtrasTotal()),
              theme,
            ),
            ...booking.extras.entries.map((e) => _buildPaymentRow(
                  e.key,
                  currencyFormat.format(e.value),
                  theme,
                )),
            const Divider(height: 24),
            _buildPaymentRow(
              'Total Amount',
              currencyFormat.format(booking.totalAmount),
              theme,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, ThemeData theme, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isTotal ? theme.primaryColor : Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? theme.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateExtrasTotal() {
    return booking.extras.values.fold(0, (sum, price) => sum + price);
  }
}
