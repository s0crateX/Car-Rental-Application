import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/models/car%20owner%20%20models/booking%20model/rent.dart';
import 'package:car_rental_app/presentation/screens/Car%20Owner/bookings/widgets/booking_info_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OwnerRentalsHistoryScreen extends StatefulWidget {
  const OwnerRentalsHistoryScreen({super.key});

  @override
  State<OwnerRentalsHistoryScreen> createState() =>
      _OwnerRentalsHistoryScreenState();
}

class _OwnerRentalsHistoryScreenState extends State<OwnerRentalsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final ownerId = authService.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rentals History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rent_completed')
            .where('ownerId', isEqualTo: ownerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No rental history found.'));
          }

          final rentalDocs = snapshot.data!.docs;
          final rentals = rentalDocs
              .map((doc) => Rent.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: rentals.length,
            itemBuilder: (context, index) {
              final rent = rentals[index];
              return BookingInfoCard(
                rent: rent,
                isHistory: true,
                isCarOwner: true,
              );
            },
          );
        },
      ),
    );
  }
}