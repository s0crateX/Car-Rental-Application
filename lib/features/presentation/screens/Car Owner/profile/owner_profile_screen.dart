import 'package:flutter/material.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Owner Profile',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
