import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../models/Firebase_car_model.dart';
import '../../../../../models/review_model.dart';
import '../../../../../core/services/review_service.dart';
import '../../../../../core/authentication/auth_service.dart';
import 'add_review_dialog.dart';

class ReviewsTabContent extends StatefulWidget {
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
  State<ReviewsTabContent> createState() => _ReviewsTabContentState();
}

class _ReviewsTabContentState extends State<ReviewsTabContent> {
  final ReviewService _reviewService = ReviewService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact header with rating and add review button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    widget.sectionTitleBuilder('Reviews'),
                    const SizedBox(width: 8),
                    // Real-time rating and review count from Cars collection
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Cars')
                          .doc(widget.car.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final carData = snapshot.data!.data() as Map<String, dynamic>;
                          final rating = (carData['rating'] ?? 0.0).toDouble();
                          final reviewCount = (carData['reviewCount'] ?? 0).toInt();
                          
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 14),
                              const SizedBox(width: 2),
                              Text(
                                '${rating.toStringAsFixed(1)} (${reviewCount})',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.amber[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        }
                        // Fallback to cached values while loading
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.car.rating.toStringAsFixed(1)} (${widget.car.reviewCount})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.amber[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (authService.isAuthenticated)
                Container(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddReviewDialog(context),
                    icon: SvgPicture.asset(
                       'assets/svg/plus.svg',
                       width: 14,
                       height: 14,
                       colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                     ),
                    label: const Text('Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Reviews list
          StreamBuilder<List<ReviewModel>>(
            stream: _reviewService.getReviewsForCarStream(widget.car.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading reviews',
                          style: theme.textTheme.titleMedium?.copyWith(
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
                return _buildEmptyState(context);
              }

              return Column(
                children: [
                  ...reviews.map((review) => _buildReviewCard(context, review)),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
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
            const SizedBox(height: 4),
            Text(
              'Be the first to review this car',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            if (authService.isAuthenticated) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddReviewDialog(context),
                icon: const Icon(Icons.rate_review, size: 16),
                label: const Text('Write First Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, ReviewModel review) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context);
    final isCurrentUser = authService.user?.uid == review.userId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact user info and rating
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  backgroundImage: review.userProfileImage.isNotEmpty
                      ? NetworkImage(review.userProfileImage)
                      : null,
                  child: review.userProfileImage.isEmpty
                      ? Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                          size: 16,
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
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Text(
                                'Verified',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green[700],
                                  fontSize: 9,
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
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isCurrentUser)
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 18,
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditReviewDialog(context, review);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, review);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 14),
                            SizedBox(width: 6),
                            Text('Edit', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        height: 36,
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 14, color: Colors.red),
                            SizedBox(width: 6),
                            Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Review text
            Text(
              review.reviewText,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddReviewDialog(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Check if user already has a review for this car
    final existingReview = await _reviewService.getUserReviewForCar(
      authService.user!.uid,
      widget.car.id,
    );

    if (existingReview != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already reviewed this car. You can edit your existing review.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddReviewDialog(
        carId: widget.car.id,
        carBrand: widget.car.brand,
        carModel: widget.car.model,
        carYear: widget.car.year,
      ),
    );

    if (result == true) {
      // Review was submitted successfully, the StreamBuilder will automatically update
    }
  }

  Future<void> _showEditReviewDialog(BuildContext context, ReviewModel review) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddReviewDialog(
        carId: widget.car.id,
        carBrand: widget.car.brand,
        carModel: widget.car.model,
        carYear: widget.car.year,
        existingReview: review,
      ),
    );

    if (result == true) {
      // Review was updated successfully, the StreamBuilder will automatically update
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, ReviewModel review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete your review? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _reviewService.deleteReview(review.id, widget.car.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete review'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
