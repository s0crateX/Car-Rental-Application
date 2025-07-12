import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:provider/provider.dart';
import '../../../../../core/services/booking_service.dart';
import '../../../../../models/car owner  models/booking model/rent.dart';
import '../../../../../core/authentication/auth_service.dart';
import 'booking_info_card.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final BookingService _bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.user?.uid;

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _bookingService.getOwnedCars(currentUserId!),
            builder: (context, carSnapshot) {
              if (!carSnapshot.hasData) {
                return const SizedBox(); // Or a loading indicator
              }
              final ownedCarIds =
                  carSnapshot.data!.docs.map((doc) => doc.id).toList();

              return StreamBuilder<Map<String, int>>(
                stream: _bookingService.getBookingCounts(ownedCarIds, 'rent_approve'),
                builder: (context, snapshot) {
                  final rentNowCount = snapshot.data?['rentNow'] ?? 0;
                  final reserveCount = snapshot.data?['reserve'] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Approved Reservations',
                            reserveCount.toString(),
                            Icons.event_note,
                            AppTheme.mediumBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Approved Rentals',
                            rentNowCount.toString(),
                            Icons.pending_actions,
                            AppTheme.lightBlue,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: _buildReservationsList(currentUserId),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList(String? currentUserId) {
    if (currentUserId == null) {
      return const Center(
        child: Text(
          'Please log in to view bookings.',
          style: TextStyle(color: AppTheme.white),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _bookingService.getOwnedCars(currentUserId),
      builder: (context, carSnapshot) {
        if (carSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (carSnapshot.hasError) {
          return Center(
              child: Text('Error: ${carSnapshot.error}',
                  style: const TextStyle(color: AppTheme.white)));
        }
        if (!carSnapshot.hasData || carSnapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No cars found. Add cars to see booking history.',
                  style: TextStyle(color: AppTheme.white)));
        }

        final ownedCarIds =
            carSnapshot.data!.docs.map((doc) => doc.id).toList();

        if (ownedCarIds.isEmpty) {
          return const Center(
            child: Text(
              'No bookings found.',
              style: TextStyle(color: AppTheme.white),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: _bookingService.getBookings(ownedCarIds, 'rent_approve'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: AppTheme.white)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text('No bookings found.',
                      style: TextStyle(color: AppTheme.white)));
            }

            final bookings = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Rent.fromMap(data..['id'] = doc.id);
            }).toList();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return BookingInfoCard(rent: booking, isHistory: true);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
                color: AppTheme.paleBlue,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}