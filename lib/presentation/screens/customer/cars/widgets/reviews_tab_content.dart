import 'package:flutter/material.dart';
import '../../../../../models/Firebase_car_model.dart';

class ReviewsTabContent extends StatelessWidget {
  final CarModel car;
  final Widget Function(String) sectionTitleBuilder;
  final String Function(DateTime) formatDate;

  const ReviewsTabContent({
    super.key,
    required this.car,
    required this.sectionTitleBuilder,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: sectionTitleBuilder('Customer Reviews')),
              // Since Firebase model doesn't have rating, we'll use a placeholder
              Text(
                'Average: 4.5',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.amber[800]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Since Firebase model doesn't have reviews, we'll show a placeholder message
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reviews yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to review this car',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Add some bottom padding to ensure content doesn't get cut off
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
