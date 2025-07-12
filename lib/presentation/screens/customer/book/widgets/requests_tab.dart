import 'package:flutter/material.dart';
import 'booking_list.dart';

class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const BookingList(collection: 'rent_request');
  }
}