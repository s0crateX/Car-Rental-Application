import 'package:flutter/material.dart';
import '../../../../../../shared/data/sample_bookings.dart';
import '../../../../../../shared/models/booking_model.dart';
import 'widgets/booking_list_item.dart';

class OwnerBookingsScreen extends StatefulWidget {
  const OwnerBookingsScreen({Key? key}) : super(key: key);

  @override
  State<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends State<OwnerBookingsScreen> {
  late List<BookingModel> _bookings;

  @override
  void initState() {
    super.initState();
    _bookings = SampleBookings.getSampleBookings();
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
              child: Text(
                'Bookings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 26),
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
                      // TODO: Show booking details modal/screen
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Booking Details'),
                          content: Text('Details for booking: \\${_bookings[index].id}'),
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
