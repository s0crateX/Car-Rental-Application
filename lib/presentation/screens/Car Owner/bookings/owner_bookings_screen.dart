import 'package:flutter/material.dart';
import '../../../../../shared/data/sample_bookings.dart';
import '../../../../../shared/models/booking_model.dart' show BookingModel, BookingStatus;
import 'widgets/booking_list_item.dart';
import 'booking_details_screen.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  late List<BookingModel> _bookings;

  @override
  void initState() {
    super.initState();
    _bookings = SampleBookings.getSampleBookings()
        .where((booking) => booking.status != BookingStatus.completed)
        .toList()
      ..sort((a, b) {
        // Sort pending bookings to the top
        if (a.status == BookingStatus.pending && b.status != BookingStatus.pending) {
          return -1;
        } else if (a.status != BookingStatus.pending && b.status == BookingStatus.pending) {
          return 1;
        }
        return 0; // Maintain original order for other statuses
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bookings',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to booking history
                    },
                    child: Text(
                      'View History',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  return BookingListItem(
                    booking: _bookings[index],
                    onViewDetails: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BookingDetailsScreen(
                            booking: _bookings[index],
                            onStatusUpdated: (newStatus) {
                              setState(() {
                                _bookings[index] = _bookings[index].copyWith(status: newStatus);
                                // Re-sort the list after status update
                                _bookings.sort((a, b) {
                                  if (a.status == BookingStatus.pending && b.status != BookingStatus.pending) {
                                    return -1;
                                  } else if (a.status != BookingStatus.pending && b.status == BookingStatus.pending) {
                                    return 1;
                                  }
                                  return 0;
                                });
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
