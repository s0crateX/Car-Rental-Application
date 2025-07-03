import 'package:flutter/material.dart';
import '../../../../shared/models/Mock Model/booking_model.dart';
import 'booking details widgets/widgets.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel booking;
  final Function(BookingStatus)? onStatusUpdated;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
    this.onStatusUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Profile Card
            CustomerProfileCard(customer: booking.customer),
            const SizedBox(height: 16),

            // Booking Status Card
            BookingStatusCard(booking: booking),
            const SizedBox(height: 16),

            // Car Details Card
            CarDetailsCard(car: booking.car),
            const SizedBox(height: 16),

            // Rental Period Card
            RentalPeriodCard(booking: booking),
            const SizedBox(height: 16),

            // Payment Summary Card
            PaymentSummaryCard(booking: booking),
            const SizedBox(height: 16),

            // Extra Charges Card
            ExtraChargesCard(booking: booking),
            const SizedBox(height: 16),

            // Customer Notes Card
            NotesCard(notes: booking.notes),
            const SizedBox(height: 16),

            // Action Buttons
            if (onStatusUpdated != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                child: BookingActionButtons(
                  status: booking.status,
                  onStatusUpdated: (newStatus) {
                    onStatusUpdated?.call(newStatus);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
