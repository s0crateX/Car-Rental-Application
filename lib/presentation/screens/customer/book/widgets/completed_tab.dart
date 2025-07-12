import 'package:flutter/material.dart';
import 'booking_list.dart';

class CompletedTab extends StatelessWidget {
  const CompletedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const BookingList(collection: 'rent_completed');
  }
}