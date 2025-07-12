import 'package:flutter/material.dart';
import 'booking_list.dart';

class ApprovedTab extends StatelessWidget {
  const ApprovedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const BookingList(collection: 'rent_approve');
  }
}