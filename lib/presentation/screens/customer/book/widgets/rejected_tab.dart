import 'package:flutter/material.dart';
import 'booking_list.dart';

class RejectedTab extends StatelessWidget {
  const RejectedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const BookingList(collection: 'rent_rejected');
  }
}