import 'package:flutter/material.dart';
import '../../../../../../shared/models/car_model.dart';
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              sectionTitleBuilder('Customer Reviews'),
              Text(
                'Average: ${car.rating}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.amber[800],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...car.reviews.map((review) {
            return ReviewItem(
              name: review['userName'] as String,
              avatar: review['userAvatar'] as String,
              rating: (review['rating'] as double),
              comment: review['comment'] as String,
              date: review['date'] as String,
              formattedDate: formatDate(
                DateTime.parse(review['date'] as String),
              ),
            );
          }),
        ],
      ),
    );
  }
}
