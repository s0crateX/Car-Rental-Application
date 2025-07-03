import 'package:flutter/material.dart';
import '../../../../../shared/models/Mock Model/car_model.dart';
import 'review_item.dart';

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
              Text(
                'Average: ${car.rating}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.amber[800]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...car.reviews.map((review) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ReviewItem(
                name: review['userName'] as String,
                avatar: review['userAvatar'] as String,
                rating: (review['rating'] as double),
                comment: review['comment'] as String,
                date: review['date'] as String,
                formattedDate: formatDate(
                  DateTime.parse(review['date'] as String),
                ),
              ),
            );
          }),
          // Add some bottom padding to ensure content doesn't get cut off
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
