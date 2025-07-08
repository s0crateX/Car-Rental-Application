import 'package:flutter/material.dart';
import 'booking_option_card.dart';

enum BookingType { rentNow, reserve }

class BookingOptionsSelector extends StatelessWidget {
  final BookingType selectedOption;
  final ValueChanged<BookingType> onOptionSelected;

  const BookingOptionsSelector({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Option',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: BookingOptionCard(
                title: 'Rent Now',
                icon: Icons.key_outlined,
                isSelected: selectedOption == BookingType.rentNow,
                onTap: () => onOptionSelected(BookingType.rentNow),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BookingOptionCard(
                title: 'Reserve',
                icon: Icons.calendar_today_outlined,
                isSelected: selectedOption == BookingType.reserve,
                onTap: () => onOptionSelected(BookingType.reserve),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
