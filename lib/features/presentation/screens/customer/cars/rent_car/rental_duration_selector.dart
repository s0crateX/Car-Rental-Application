import 'package:flutter/material.dart';

class RentalDurationSelector extends StatelessWidget {
  final int rentalDays;
  final ValueChanged<int> onChanged;

  const RentalDurationSelector({
    Key? key,
    required this.rentalDays,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rental Duration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: rentalDays > 1
                  ? () => onChanged(rentalDays - 1)
                  : null,
            ),
            Text(
              ' $rentalDays day${rentalDays > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(rentalDays + 1),
            ),
          ],
        ),
      ],
    );
  }
}
