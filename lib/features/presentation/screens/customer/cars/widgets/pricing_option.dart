import 'package:flutter/material.dart';

class PricingOption extends StatelessWidget {
  final String period;
  final Widget price;

  const PricingOption({
    Key? key,
    required this.period,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(period, style: Theme.of(context).textTheme.bodyMedium),
          price,
        ],
      ),
    );
  }
}
