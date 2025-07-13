import 'package:car_rental_app/models/Firebase_car_model.dart';
import 'package:car_rental_app/presentation/screens/customer/cars/car_details_screen.dart';
import 'package:car_rental_app/shared/common_widgets/car_card_compact.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerCarsScreen extends StatelessWidget {
  final String ownerId;
  final String ownerName;

  const OwnerCarsScreen({Key? key, required this.ownerId, required this.ownerName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$ownerName's Cars"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Cars')
            .where('carOwnerDocumentId', isEqualTo: ownerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No cars found for this owner.'));
          }

          final carDocs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.7,
            ),
            itemCount: carDocs.length,
            itemBuilder: (context, index) {
              final car = CarModel.fromFirestore(carDocs[index]);
              return CarCardCompact(
                car: car,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarDetailsScreen(car: car),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}