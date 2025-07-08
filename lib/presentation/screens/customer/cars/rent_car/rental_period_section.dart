import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'booking_options_selector.dart';

class RentalPeriodSection extends StatelessWidget {
  final BookingType bookingType;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectEndDate;

  const RentalPeriodSection({
    super.key,
    required this.bookingType,
    required this.startDate,
    required this.endDate,
    required this.onSelectStartDate,
    required this.onSelectEndDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReserve = bookingType == BookingType.reserve;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isReserve ? 'Reservation Period' : 'Rental Period',
          style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context: context,
                label: isReserve ? 'Start Date & Time' : 'Pickup/Deliver Time',
                date: startDate,
                onTap: onSelectStartDate,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                context: context,
                label: isReserve ? 'End Date & Time' : 'End of Rental',
                date: endDate,
                onTap: onSelectEndDate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);
    final displayValue =
        date != null ? DateFormat('MMM d, hh:mm a').format(date) : 'Select';

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDisabled
              ? theme.colorScheme.surfaceContainerLowest.withOpacity(0.5)
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    displayValue,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
