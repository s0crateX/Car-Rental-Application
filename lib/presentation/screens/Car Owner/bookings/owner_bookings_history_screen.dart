import 'package:flutter/material.dart';
import '../../../../../shared/data/sample_bookings.dart';
import '../../../../../shared/models/booking_model.dart' show BookingModel, BookingStatus;
import 'widgets/booking_list_item.dart';
import 'booking_details_screen.dart';

class OwnerBookingsHistoryScreen extends StatefulWidget {
  const OwnerBookingsHistoryScreen({super.key});

  @override
  State<OwnerBookingsHistoryScreen> createState() => _OwnerBookingsHistoryScreenState();
}

class _OwnerBookingsHistoryScreenState extends State<OwnerBookingsHistoryScreen> {
  late List<BookingModel> _completedBookings;
  late List<BookingModel> _cancelledBookings;
  bool _showCompleted = true;
  bool _showCancelled = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final allBookings = SampleBookings.getSampleBookings();
    _completedBookings = allBookings
        .where((booking) => booking.status == BookingStatus.completed)
        .toList()
      ..sort((a, b) => b.endDate.compareTo(a.endDate)); // Most recent first

    _cancelledBookings = allBookings
        .where((booking) => booking.status == BookingStatus.cancelled)
        .toList()
      ..sort((a, b) => b.endDate.compareTo(a.endDate)); // Most recent first
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Booking History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Completed (${_completedBookings.length})',
                  selected: _showCompleted,
                  onSelected: (selected) {
                    setState(() => _showCompleted = selected);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Cancelled (${_cancelledBookings.length})',
                  selected: _showCancelled,
                  onSelected: (selected) {
                    setState(() => _showCancelled = selected);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Bookings list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                if (_showCompleted && _completedBookings.isNotEmpty) ...[
                  _buildSectionHeader('Completed Bookings'),
                  ..._buildBookingList(_completedBookings),
                ],
                if (_showCancelled && _cancelledBookings.isNotEmpty) ...[
                  _buildSectionHeader('Cancelled Bookings'),
                  ..._buildBookingList(_cancelledBookings),
                ],
                if ((_showCompleted && _completedBookings.isEmpty) ||
                    (_showCancelled && _cancelledBookings.isEmpty))
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No bookings found',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).primaryColor : Colors.black87,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? Theme.of(context).primaryColor : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  List<Widget> _buildBookingList(List<BookingModel> bookings) {
    return bookings
        .map((booking) => BookingListItem(
              booking: booking,
              onViewDetails: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookingDetailsScreen(
                      booking: booking,
                      onStatusUpdated: (newStatus) {
                        // Refresh the list if status changes
                        setState(() {
                          _loadBookings();
                        });
                      },
                    ),
                  ),
                );
              },
            ))
        .toList();
  }
}
