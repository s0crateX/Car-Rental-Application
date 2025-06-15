import 'package:flutter/material.dart';

class DiscountItem extends StatelessWidget {
  final String title;
  final String discount;

  const DiscountItem({super.key, required this.title, required this.discount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              discount,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
