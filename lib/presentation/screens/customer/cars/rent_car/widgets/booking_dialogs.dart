import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';

class ConfirmBookingDialog extends StatelessWidget {
  final String period;
  final String paymentMode;
  final String startDate;
  final String endDate;
  final String? notes;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmBookingDialog({
    super.key,
    required this.period,
    required this.paymentMode,
    required this.startDate,
    required this.endDate,
    this.notes,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: AppTheme.navy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.mediumBlue, AppTheme.lightBlue],
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Icon(Icons.help_outline_rounded, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 18),
            Text(
              'Confirm Booking',
              style: TextStyle(
                color: AppTheme.paleBlue,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please review your booking details before confirming.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 22),
            _BookingDetailRow(label: 'Rental Period', value: period),
            _BookingDetailRow(label: 'Payment Mode', value: paymentMode),
            _BookingDetailRow(label: 'Start Date', value: startDate),
            _BookingDetailRow(label: 'End Date', value: endDate),
            if (notes != null && notes!.trim().isNotEmpty)
              _BookingDetailRow(label: 'Notes', value: notes!),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.mediumBlue,
                      side: BorderSide(color: AppTheme.mediumBlue, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookingConfirmedDialog extends StatelessWidget {
  final String bookingId;
  final String period;
  final String paymentMode;
  final String startDate;
  final String endDate;
  final String? notes;
  final bool receiptUploaded;
  final VoidCallback onOk;

  const BookingConfirmedDialog({
    super.key,
    required this.bookingId,
    required this.period,
    required this.paymentMode,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.receiptUploaded = false,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      backgroundColor: AppTheme.navy,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.mediumBlue, AppTheme.lightBlue],
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 18),
            Text(
              'Booking Confirmed!',
              style: TextStyle(
                color: AppTheme.paleBlue,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your booking has been successfully submitted.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.88),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 22),
            _BookingDetailRow(label: 'Booking ID', value: bookingId),
            _BookingDetailRow(label: 'Rental Period', value: period),
            _BookingDetailRow(label: 'Payment Mode', value: paymentMode),
            _BookingDetailRow(label: 'Start Date', value: startDate),
            _BookingDetailRow(label: 'End Date', value: endDate),
            if (notes != null && notes!.trim().isNotEmpty)
              _BookingDetailRow(label: 'Notes', value: notes!),
            if (receiptUploaded) ...[
              const SizedBox(height: 8),
              const Text(
                'Receipt uploaded!',
                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w600),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onOk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _BookingDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: AppTheme.paleBlue.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
