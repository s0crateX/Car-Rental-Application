import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../shared/models/booking_model.dart';

class BookingListItem extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onViewDetails;

  const BookingListItem({
    Key? key,
    required this.booking,
    required this.onViewDetails,
  }) : super(key: key);

  Color _statusColor(BuildContext context) {
    switch (booking.status) {
      case BookingStatus.approved:
        return Colors.greenAccent.shade400;
      case BookingStatus.completed:
        return Colors.blueAccent.shade100;
      case BookingStatus.cancelled:
        return Colors.redAccent.shade200;
      case BookingStatus.pending:
        return Theme.of(context).colorScheme.secondary;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final df = DateFormat('MMM d, yyyy');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      elevation: 1.5,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Car image (if available)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: booking.car.image.isNotEmpty
                  ? Image.asset(
                      booking.car.image,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 48,
                      height: 48,
                      color: theme.colorScheme.primary.withOpacity(0.13),
                      child: Icon(Icons.directions_car, size: 24, color: theme.colorScheme.primary),
                    ),
            ),
            const SizedBox(width: 10),
            // Booking details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.car.name,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Renter: ${booking.id}', // Placeholder for renter name (replace with real data)
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${df.format(booking.startDate)} – ${df.format(booking.endDate)}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                        decoration: BoxDecoration(
                          color: _statusColor(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onViewDetails,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('View Details', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
