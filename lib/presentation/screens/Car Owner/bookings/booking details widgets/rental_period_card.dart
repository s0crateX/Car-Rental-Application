import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/models/Mock Model/booking_model.dart';

class RentalPeriodCard extends StatelessWidget {
  final BookingModel booking;

  const RentalPeriodCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rental Period',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Pick-up',
              '${dateFormat.format(booking.startDate)} at ${timeFormat.format(booking.startDate)}',
              theme,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Drop-off',
              '${dateFormat.format(booking.endDate)} at ${timeFormat.format(booking.endDate)}',
              theme,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Duration',
              '${booking.endDate.difference(booking.startDate).inDays} days',
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
