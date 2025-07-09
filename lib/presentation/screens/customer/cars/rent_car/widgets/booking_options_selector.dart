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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact title row with icon
        Row(
          children: [
            Icon(Icons.tune, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              'Booking Option',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Options container
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: BookingOptionCard(
                  title: 'Rent Now',
                  subtitle: 'Immediate rental',
                  icon: Icons.key_rounded,
                  isSelected: selectedOption == BookingType.rentNow,
                  onTap: () => onOptionSelected(BookingType.rentNow),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: BookingOptionCard(
                  title: 'Reserve',
                  subtitle: 'Book for later',
                  icon: Icons.calendar_today_rounded,
                  isSelected: selectedOption == BookingType.reserve,
                  onTap: () => onOptionSelected(BookingType.reserve),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
