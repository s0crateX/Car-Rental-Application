import 'package:flutter/material.dart';
import '../../../../../../shared/models/booking_model.dart';

class BookingActionButtons extends StatelessWidget {
  final BookingStatus status;
  final Function(BookingStatus) onStatusUpdated;
  
  const BookingActionButtons({
    super.key,
    required this.status,
    required this.onStatusUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (status == BookingStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => onStatusUpdated(BookingStatus.approved),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.green),
              ),
              child: const Text(
                'Approve',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => onStatusUpdated(BookingStatus.cancelled),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text(
                'Reject',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      );
    } else if (status == BookingStatus.approved) {
      return ElevatedButton(
        onPressed: () => onStatusUpdated(BookingStatus.completed),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          minimumSize: const Size(double.infinity, 48),
        ),
        child: const Text('Mark as Completed'),
      );
    }
    
    return const SizedBox.shrink();
  }
}
