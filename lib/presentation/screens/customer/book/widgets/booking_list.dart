import 'package:car_rental_app/core/services/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/presentation/screens/Car%20Owner/bookings/widgets/booking_info_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../models/car owner  models/booking model/rent.dart';

class BookingList extends StatelessWidget {
  final String collection;
  const BookingList({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.user?.uid;
    final BookingService bookingService = BookingService();

    if (currentUserId == null) {
      return const Center(
        child: Text(
          'Please log in to view your bookings.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: bookingService.getBookingsByCustomer(currentUserId, collection),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text('No bookings found.',
                  style: TextStyle(color: Colors.white)));
        }

        final bookings = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Rent.fromMap(data..['id'] = doc.id);
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return BookingInfoCard(
              rent: booking,
              isHistory: true,
              isRequest: collection == 'rent_request',
              isCarOwner: false, // This is the customer view
            );
          },
        );
      },
    );
  }
}