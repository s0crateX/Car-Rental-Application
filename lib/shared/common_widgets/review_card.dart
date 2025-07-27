import 'package:flutter/material.dart';
import '../../../../../models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool showCarInfo;
  final VoidCallback? onTap;

  const ReviewCard({
    super.key,
    required this.review,
    this.showCarInfo = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact user info and rating
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    backgroundImage: review.userProfileImage.isNotEmpty
                        ? NetworkImage(review.userProfileImage)
                        : null,
                    child: review.userProfileImage.isEmpty
                        ? Icon(
                            Icons.person,
                            color: theme.colorScheme.primary,
                            size: 14,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                review.userName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (review.isVerified) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                                ),
                                child: Text(
                                  'Verified',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.green[700],
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < review.rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 12,
                              );
                            }),
                            const SizedBox(width: 4),
                            Text(
                              review.formattedDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Car info (if enabled)
              if (showCarInfo && review.carBrand != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${review.carBrand} ${review.carModel} ${review.carYear}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Review text
              Text(
                review.reviewText,
                style: theme.textTheme.bodySmall,
                maxLines: showCarInfo ? 3 : null,
                overflow: showCarInfo ? TextOverflow.ellipsis : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}