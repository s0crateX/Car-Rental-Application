import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/models/Mock Model/booking_model.dart';

class BookingListItem extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onViewDetails;

  const BookingListItem({
    super.key,
    required this.booking,
    required this.onViewDetails,
  });

  Color _statusColor(BuildContext context) {
    switch (booking.status) {
      case BookingStatus.approved:
        return const Color(0xFF10B981); // Emerald green
      case BookingStatus.completed:
        return const Color(0xFF3B82F6); // Blue
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444); // Red
      case BookingStatus.pending:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  Color _statusBackgroundColor(BuildContext context) {
    switch (booking.status) {
      case BookingStatus.approved:
        return const Color(0xFF10B981).withOpacity(0.1);
      case BookingStatus.completed:
        return const Color(0xFF3B82F6).withOpacity(0.1);
      case BookingStatus.cancelled:
        return const Color(0xFFEF4444).withOpacity(0.1);
      case BookingStatus.pending:
        return const Color(0xFFF59E0B).withOpacity(0.1);
    }
  }

  String _statusText() {
    switch (booking.status) {
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.pending:
        return 'Pending';
    }
  }

  IconData _statusIcon() {
    switch (booking.status) {
      case BookingStatus.approved:
        return Icons.check_circle_outline;
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel_outlined;
      case BookingStatus.pending:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('MMM d, yyyy');
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onViewDetails,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with car info and status
                  Row(
                    children: [
                      // Car image with modern styling
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              booking.car.image.isNotEmpty
                                  ? Image.asset(
                                    booking.car.image,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  )
                                  : Icon(
                                    Icons.directions_car_rounded,
                                    size: 28,
                                    color: theme.colorScheme.primary,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Car name and renter info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.car.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Booking ID: ${booking.id}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBackgroundColor(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _statusIcon(),
                              size: 14,
                              color: _statusColor(context),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _statusText(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _statusColor(context),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date range with modern styling
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${df.format(booking.startDate)} – ${df.format(booking.endDate)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: theme.colorScheme.primary.withOpacity(0.6),
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
  }
}
