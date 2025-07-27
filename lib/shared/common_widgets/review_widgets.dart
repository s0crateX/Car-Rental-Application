import 'package:flutter/material.dart';
import '../../../../../models/review_model.dart';
import '../../../../../core/services/review_service.dart';
import '../../../../../shared/common_widgets/review_card.dart';

class RecentReviewsWidget extends StatelessWidget {
  final int limit;
  final bool showCarInfo;

  const RecentReviewsWidget({
    super.key,
    this.limit = 5,
    this.showCarInfo = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviewService = ReviewService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'Recent Reviews',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<ReviewModel>>(
          future: reviewService.getRecentReviews(limit: limit),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 36,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading reviews',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final reviews = snapshot.data ?? [];

            if (reviews.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 36,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No reviews yet',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: reviews
                    .map((review) => ReviewCard(
                          review: review,
                          showCarInfo: showCarInfo,
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class TopRatedCarsWidget extends StatelessWidget {
  final int limit;

  const TopRatedCarsWidget({
    super.key,
    this.limit = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviewService = ReviewService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'Top Rated Cars',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<String>>(
          future: reviewService.getTopRatedCarIds(limit: limit),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 36,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading top rated cars',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final carIds = snapshot.data ?? [];

            if (carIds.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.star_outline,
                        size: 36,
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No rated cars yet',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemCount: carIds.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 8.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Car image placeholder
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.directions_car,
                                  size: 24,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Car ${carIds[index]}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            FutureBuilder<double>(
                              future: reviewService.getAverageRatingForCar(carIds[index]),
                              builder: (context, ratingSnapshot) {
                                if (ratingSnapshot.hasData) {
                                  final rating = ratingSnapshot.data!;
                                  return Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 12,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}