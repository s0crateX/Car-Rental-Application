import 'package:flutter/material.dart';
import '../../../../../../shared/models/booking_model.dart';

class BookingActionsSection extends StatelessWidget {
  final BookingModel booking;
  const BookingActionsSection({Key? key, required this.booking}) : super(key: key);

  bool get canCancel {
    // If pending and created more than 24 hours ago
    return booking.status == BookingStatus.pending &&
        DateTime.now().difference(booking.createdAt).inHours >= 24;
  }

  bool get canExtend {
    return booking.status == BookingStatus.approved;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (canCancel)
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add cancel booking logic
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking cancelled (mock logic)')));
              },
              icon: const Icon(Icons.cancel_rounded, size: 22),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: theme.colorScheme.error.withOpacity(0.25),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
