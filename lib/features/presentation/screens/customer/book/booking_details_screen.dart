import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';
import '../../../../../shared/data/sample_bookings.dart';
import '../../../../../shared/models/booking_model.dart';

import 'widgets/booking_info_section.dart';
import 'widgets/booking_status_section.dart';
import 'widgets/booking_actions_section.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel? booking;
  const BookingDetailsScreen({super.key, this.booking});

  @override
  Widget build(BuildContext context) {
    // Use passed booking or fallback to sample
    final BookingModel bookingModel =
        booking ?? SampleBookings.getSampleBookings().first;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Booking Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svg/arrow-left.svg',
            colorFilter: ColorFilter.mode(AppTheme.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
