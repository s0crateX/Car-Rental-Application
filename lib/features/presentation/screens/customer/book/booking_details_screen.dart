import 'package:flutter/material.dart';
import '../../../../../shared/data/sample_bookings.dart';
import '../../../../../shared/models/booking_model.dart';

import 'widgets/booking_info_section.dart';
import 'widgets/booking_status_section.dart';
import 'widgets/booking_actions_section.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel? booking;
  const BookingDetailsScreen({Key? key, this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use passed booking or fallback to sample
    final BookingModel bookingModel = booking ?? SampleBookings.getSampleBookings().first;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Booking Details'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookingInfoSection(booking: bookingModel),
              const SizedBox(height: 18),
              BookingActionsSection(booking: bookingModel),
            ],
          ),
        ),
      ),
    );
  }
}
