# Review Feature Documentation

## Overview
The review feature allows customers to submit, edit, and delete reviews for cars they have rented. Reviews are stored in a separate Firebase collection called `Reviews` and are linked to both cars and users.

## Components

### 1. ReviewModel (`lib/models/review_model.dart`)
- Represents a review with all necessary fields
- Includes user information, car reference, rating, and review text
- Has helper methods for formatting dates and displaying stars
- Supports verified reviews for users who have actually rented the car

### 2. ReviewService (`lib/core/services/review_service.dart`)
- Handles all Firebase operations for reviews
- Provides CRUD operations (Create, Read, Update, Delete)
- Automatically updates car ratings and review counts
- Includes real-time streams for live updates
- Checks if users have rented cars for verified reviews

### 3. AddReviewDialog (`lib/presentation/screens/customer/cars/widgets/add_review_dialog.dart`)
- Modal dialog for adding and editing reviews
- Interactive star rating system
- Form validation
- Handles both new reviews and editing existing ones

### 4. ReviewsTabContent (`lib/presentation/screens/customer/cars/widgets/reviews_tab_content.dart`)
- Updated to display real reviews from Firebase
- Shows average rating and review count
- Allows authenticated users to add reviews
- Displays reviews with user info, ratings, and timestamps
- Supports editing and deleting user's own reviews

### 5. ReviewCard (`lib/shared/common_widgets/review_card.dart`)
- Reusable widget for displaying reviews
- Can optionally show car information
- Compact design for use in lists

## Firebase Structure

### Reviews Collection
```
Reviews/
├── {reviewId}/
│   ├── carId: string
│   ├── userId: string
│   ├── userName: string
│   ├── userProfileImage: string
│   ├── rating: number (1.0-5.0)
│   ├── reviewText: string
│   ├── createdAt: timestamp
│   ├── updatedAt: timestamp
│   ├── isVerified: boolean
│   ├── carBrand: string
│   ├── carModel: string
│   └── carYear: string
```

### Cars Collection Updates
The service automatically updates the following fields in the Cars collection:
- `rating`: Average rating from all reviews
- `reviewCount`: Total number of reviews

## Features

### 1. Review Submission
- Users can submit reviews with 1-5 star ratings
- Review text is required (minimum 10 characters)
- Reviews are automatically timestamped
- Verified status is set based on rental history

### 2. Review Management
- Users can edit their own reviews
- Users can delete their own reviews
- Real-time updates when reviews are added/modified

### 3. Review Display
- Reviews are displayed in chronological order (newest first)
- Shows user profile pictures and names
- Displays star ratings and timestamps
- Verified reviews are marked with a badge

### 4. Rating Calculation
- Automatic calculation of average ratings
- Real-time updates to car rating displays
- Review count tracking

## Usage Examples

### Display Reviews for a Car
```dart
StreamBuilder<List<ReviewModel>>(
  stream: ReviewService().getReviewsForCarStream(carId),
  builder: (context, snapshot) {
    final reviews = snapshot.data ?? [];
    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return ReviewCard(review: reviews[index]);
      },
    );
  },
)
```

### Add a Review
```dart
showDialog(
  context: context,
  builder: (context) => AddReviewDialog(
    carId: car.id,
    carBrand: car.brand,
    carModel: car.model,
    carYear: car.year,
  ),
);
```

### Check User's Review for a Car
```dart
final userReview = await ReviewService().getUserReviewForCar(userId, carId);
if (userReview != null) {
  // User has already reviewed this car
}
```

## Security Considerations

1. **Authentication**: Only authenticated users can submit reviews
2. **Authorization**: Users can only edit/delete their own reviews
3. **Validation**: All inputs are validated on both client and server side
4. **Verification**: Reviews from users who have rented the car are marked as verified

## Future Enhancements

1. **Review Moderation**: Admin panel for reviewing and moderating reviews
2. **Review Replies**: Allow car owners to reply to reviews
3. **Review Filtering**: Filter reviews by rating, date, or verification status
4. **Review Analytics**: Dashboard showing review trends and statistics
5. **Review Notifications**: Notify car owners when they receive new reviews

## Installation

The review feature is ready to use. Make sure you have:
1. Firebase Firestore configured
2. Authentication service set up
3. Provider package for state management

No additional setup is required as the service will automatically create the Reviews collection when the first review is submitted.