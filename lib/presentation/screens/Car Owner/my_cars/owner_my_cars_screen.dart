import 'package:flutter/material.dart';

class OwnerMyCarsScreen extends StatelessWidget {
  const OwnerMyCarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('My Cars', style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
