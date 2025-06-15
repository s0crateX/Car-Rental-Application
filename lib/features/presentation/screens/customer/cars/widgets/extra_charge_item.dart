import 'package:flutter/material.dart';

class ExtraChargeItem extends StatelessWidget {
  final String title;
  final Widget price;

  const ExtraChargeItem({super.key, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          price,
        ],
      ),
    );
  }
}
