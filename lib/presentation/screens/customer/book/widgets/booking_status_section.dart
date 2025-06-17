import 'package:flutter/material.dart';
import '../../../../../shared/models/booking_model.dart';

class BookingStatusSection extends StatelessWidget {
  final BookingModel booking;
  const BookingStatusSection({super.key, required this.booking});

  Color _statusColor(BuildContext context) {
    switch (booking.status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.approved:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  String _statusText() {
    switch (booking.status) {
      case BookingStatus.pending:
        return 'Pending Approval';
      case BookingStatus.approved:
        return 'Approved';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _statusColor(context).withOpacity(0.14),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _statusColor(context).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_rounded, color: _statusColor(context), size: 32),
          const SizedBox(width: 16),
          Text(
            _statusText(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: _statusColor(context),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
