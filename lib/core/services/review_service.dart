import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/review_model.dart';
import '../../models/Firebase_car_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'Reviews';

  // Get all reviews for a specific car
  Future<List<ReviewModel>> getReviewsForCar(String carId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('carId', isEqualTo: carId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching reviews for car: $e');
      return [];
    }
  }

  // Get reviews for a car as a stream (real-time updates)
  Stream<List<ReviewModel>> getReviewsForCarStream(String carId) {
    return _firestore
        .collection(_collectionName)
        .where('carId', isEqualTo: carId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList());
  }

  // Add a new review
  Future<bool> addReview(ReviewModel review) async {
    try {
      // Add the review to the Reviews collection
      final docRef = await _firestore.collection(_collectionName).add(review.toMap());
      
      // Update car's rating and review count
      await _updateCarRatingAndReviewCount(review.carId);
      
      return true;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  // Update an existing review
  Future<bool> updateReview(String reviewId, ReviewModel updatedReview) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(reviewId)
          .update(updatedReview.copyWith(updatedAt: DateTime.now()).toMap());
      
      // Update car's rating and review count
      await _updateCarRatingAndReviewCount(updatedReview.carId);
      
      return true;
    } catch (e) {
      print('Error updating review: $e');
      return false;
    }
  }

  // Delete a review
  Future<bool> deleteReview(String reviewId, String carId) async {
    try {
      await _firestore.collection(_collectionName).doc(reviewId).delete();
      
      // Update car's rating and review count
      await _updateCarRatingAndReviewCount(carId);
      
      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  // Get reviews by a specific user
  Future<List<ReviewModel>> getReviewsByUser(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching reviews by user: $e');
      return [];
    }
  }

  // Check if user has already reviewed a specific car
  Future<ReviewModel?> getUserReviewForCar(String userId, String carId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .where('carId', isEqualTo: carId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ReviewModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error checking user review for car: $e');
      return null;
    }
  }

  // Get average rating for a car
  Future<double> getAverageRatingForCar(String carId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('carId', isEqualTo: carId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      double totalRating = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] ?? 0.0).toDouble();
      }

      return totalRating / snapshot.docs.length;
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0.0;
    }
  }

  // Get review count for a car
  Future<int> getReviewCountForCar(String carId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('carId', isEqualTo: carId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting review count: $e');
      return 0;
    }
  }

  // Private method to update car's rating and review count
  Future<void> _updateCarRatingAndReviewCount(String carId) async {
    try {
      final averageRating = await getAverageRatingForCar(carId);
      final reviewCount = await getReviewCountForCar(carId);

      await _firestore.collection('Cars').doc(carId).update({
        'rating': averageRating,
        'reviewCount': reviewCount,
      });
    } catch (e) {
      print('Error updating car rating and review count: $e');
    }
  }

  // Get recent reviews (for dashboard or home screen)
  Future<List<ReviewModel>> getRecentReviews({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching recent reviews: $e');
      return [];
    }
  }

  // Get top-rated cars based on reviews
  Future<List<String>> getTopRatedCarIds({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('Cars')
          .where('reviewCount', isGreaterThan: 0)
          .orderBy('rating', descending: true)
          .orderBy('reviewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching top-rated cars: $e');
      return [];
    }
  }

  // Check if user has rented a car (for verified reviews)
  Future<bool> hasUserRentedCar(String userId, String carId) async {
    try {
      // Check in both pending and completed bookings
      final pendingBookings = await _firestore
          .collection('PendingBookings')
          .where('customerId', isEqualTo: userId)
          .where('carId', isEqualTo: carId)
          .get();

      final completedBookings = await _firestore
          .collection('CompletedBookings')
          .where('customerId', isEqualTo: userId)
          .where('carId', isEqualTo: carId)
          .get();

      return pendingBookings.docs.isNotEmpty || completedBookings.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user has rented car: $e');
      return false;
    }
  }
}