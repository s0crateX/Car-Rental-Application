import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../models/review_model.dart';
import '../../../../../core/services/review_service.dart';
import '../../../../../core/authentication/auth_service.dart';

class AddReviewDialog extends StatefulWidget {
  final String carId;
  final String carBrand;
  final String carModel;
  final String carYear;
  final ReviewModel? existingReview;

  const AddReviewDialog({
    super.key,
    required this.carId,
    required this.carBrand,
    required this.carModel,
    required this.carYear,
    this.existingReview,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  final ReviewService _reviewService = ReviewService();
  
  double _rating = 5.0;
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _reviewController.text = widget.existingReview!.reviewText;
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    final userData = authService.userData;

    if (user == null) {
      _showErrorSnackBar('You must be logged in to submit a review');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final hasRented = await _reviewService.hasUserRentedCar(user.uid, widget.carId);

      final review = ReviewModel(
        id: widget.existingReview?.id ?? '',
        carId: widget.carId,
        userId: user.uid,
        userName: userData?['fullName'] ?? user.displayName ?? 'Anonymous',
        userProfileImage: userData?['profileImageUrl'] ?? '',
        rating: _rating,
        reviewText: _reviewController.text.trim(),
        createdAt: widget.existingReview?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: hasRented,
        carBrand: widget.carBrand,
        carModel: widget.carModel,
        carYear: widget.carYear,
      );

      bool success;
      if (widget.existingReview != null) {
        success = await _reviewService.updateReview(widget.existingReview!.id, review);
      } else {
        success = await _reviewService.addReview(review);
      }

      if (success) {
        Navigator.of(context).pop(true);
        _showSuccessSnackBar(
          widget.existingReview != null 
            ? 'Review updated!' 
            : 'Review submitted!'
        );
      } else {
        _showErrorSnackBar('Failed to submit review. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Dialog(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: colorScheme.surface,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxHeight: 480),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Compact header
                      Row(
                        children: [
                          
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.existingReview != null ? 'Edit Review' : 'Write Review',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                              minimumSize: const Size(32, 32),
                              padding: const EdgeInsets.all(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Compact car info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_car_rounded,
                              color: colorScheme.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${widget.carBrand} ${widget.carModel} ${widget.carYear}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Compact rating section
                      Row(
                        children: [
                          Text(
                            'Rating:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return GestureDetector(
                                    onTap: () => setState(() => _rating = index + 1.0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 2),
                                      child: Icon(
                                        index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                        color: index < _rating 
                                          ? Colors.amber[600] 
                                          : colorScheme.outline,
                                        size: 24,
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(width: 8),
                                Text(
                                  '${_rating.toStringAsFixed(1)}/5',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Compact review text field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Review',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _reviewController,
                                maxLines: null,
                                expands: true,
                                maxLength: 500,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText: 'Share your experience...',
                                  hintStyle: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline.withOpacity(0.3),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: colorScheme.surfaceVariant.withOpacity(0.1),
                                  contentPadding: const EdgeInsets.all(12),
                                  counterStyle: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                style: theme.textTheme.bodySmall,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please write a review';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'Review must be at least 10 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Compact action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: _isSubmitting ? null : _submitReview,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: _isSubmitting
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text('Submitting...'),
                                      ],
                                    )
                                  : Text(widget.existingReview != null ? 'Update' : 'Submit'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}