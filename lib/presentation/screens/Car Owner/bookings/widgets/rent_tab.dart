import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:provider/provider.dart';
import '../../../../../core/services/booking_service.dart';
import '../../../../../models/car owner  models/booking model/rent.dart';
import '../../../../../core/authentication/auth_service.dart';
import 'booking_info_card.dart';

class RentTab extends StatelessWidget {
  const RentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final bookingService = BookingService();
    final currentUserId = authService.user?.uid;

    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkNavy,
        body: const Center(
          child: Text(
            'Please log in to view bookings.',
            style: TextStyle(color: AppTheme.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingService.getOwnedCars(currentUserId),
        builder: (context, carSnapshot) {
          if (carSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (carSnapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${carSnapshot.error}',
                style: const TextStyle(color: AppTheme.white),
              ),
            );
          }
          if (!carSnapshot.hasData || carSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No cars found. Add cars to see bookings.',
                style: TextStyle(color: AppTheme.white),
              ),
            );
          }

          final ownedCarIds = carSnapshot.data!.docs.map((doc) => doc.id).toList();

          if (ownedCarIds.isEmpty) {
            return const Center(
              child: Text(
                'No bookings found.',
                style: TextStyle(color: AppTheme.white),
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: bookingService.getBookings(ownedCarIds, 'rent_request'),
            builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppTheme.white),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No bookings found.',
                style: TextStyle(color: AppTheme.white),
              ),
            );
          }

              final bookings = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Rent.fromMap(data..['id'] = doc.id);
              }).toList();

              return ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return BookingInfoCard(rent: booking, isHistory: false);
                },
              );
            },
          );
        },
      ),
    );
  }


}