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
        Row(
          children: [
            Icon(
              isReserve ? Icons.event_available : Icons.schedule,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              isReserve ? 'Reservation Period' : 'Rental Period',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      context: context,
                      label:
                          isReserve
                              ? 'Start Date & Time'
                              : 'Pickup/Deliver Time',
                      date: startDate,
                      onTap: onSelectStartDate,
                      icon: Icons.play_circle_outline,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      height: 2,
                      width: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildDateField(
                      context: context,
                      label: isReserve ? 'End Date & Time' : 'End of Rental',
                      date: endDate,
                      onTap: onSelectEndDate,
                      icon: Icons.stop,
                    ),
                  ),
                ],
              ),
              if (startDate != null && endDate != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _calculateDuration(startDate!, endDate!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);
    final hasDate = date != null;
    final displayValue =
        hasDate ? DateFormat('MMM d, h:mm a').format(date) : 'Select date';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color:
                isDisabled
                    ? theme.colorScheme.surfaceContainerLowest.withOpacity(0.5)
                    : hasDate
                    ? theme.colorScheme.primary.withOpacity(0.05)
                    : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  hasDate
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : theme.colorScheme.outline.withOpacity(0.2),
              width: hasDate ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color:
                    hasDate
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color:
                            hasDate
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayValue,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color:
                            hasDate
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);

    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      if (hours > 0) {
        return '$days day${days > 1 ? 's' : ''}, $hours hour${hours > 1 ? 's' : ''}';
      }
      return '$days day${days > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '$hours hour${hours > 1 ? 's' : ''}, $minutes min${minutes > 1 ? 's' : ''}';
      }
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      final minutes = duration.inMinutes;
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }
}
