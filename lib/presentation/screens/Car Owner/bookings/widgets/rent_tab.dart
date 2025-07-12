import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import '../../../../../models/car owner  models/booking model/rent.dart';
import 'booking_info_card.dart';

class RentTab extends StatelessWidget {
  const RentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rent_request').snapshots(),
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
      ),
    );
  }


}