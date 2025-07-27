import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id; // Document ID from Firestore
  final String carId; // Reference to the car
  final String userId; // Reference to the user who wrote the review
  final String userName; // User's display name
  final String userProfileImage; // User's profile image URL (optional)
  final double rating; // Rating from 1.0 to 5.0
  final String reviewText; // The actual review content
  final DateTime createdAt; // When the review was created
  final DateTime updatedAt; // When the review was last updated
  final bool isVerified; // Whether the reviewer actually rented the car
  final String? carBrand; // Car brand for easy reference
  final String? carModel; // Car model for easy reference
  final String? carYear; // Car year for easy reference

  ReviewModel({
    required this.id,
    required this.carId,
    required this.userId,
    required this.userName,
    this.userProfileImage = '',
    required this.rating,
    required this.reviewText,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.carBrand,
    this.carModel,
    this.carYear,
  });

  // Factory constructor to create ReviewModel from Firestore document
  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel.fromMap(data, doc.id);
  }

  // Factory constructor to create ReviewModel from Map with optional document ID
  factory ReviewModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return ReviewModel(
      id: documentId ?? map['id'] ?? '',
      carId: map['carId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userProfileImage: map['userProfileImage'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewText: map['reviewText'] ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      isVerified: map['isVerified'] ?? false,
      carBrand: map['carBrand'],
      carModel: map['carModel'],
      carYear: map['carYear'],
    );
  }

  // Convert ReviewModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'userId': userId,
      'userName': userName,
      'userProfileImage': userProfileImage,
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isVerified': isVerified,
      'carBrand': carBrand,
      'carModel': carModel,
      'carYear': carYear,
    };
  }

  // Helper method to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is Timestamp) return dateTime.toDate();
    if (dateTime is String) {
      return DateTime.tryParse(dateTime) ?? DateTime.now();
    }
    return DateTime.now();
  }

  // Copy with method for updates
  ReviewModel copyWith({
    String? id,
    String? carId,
    String? userId,
    String? userName,
    String? userProfileImage,
    double? rating,
    String? reviewText,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    String? carBrand,
    String? carModel,
    String? carYear,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      carBrand: carBrand ?? this.carBrand,
      carModel: carModel ?? this.carModel,
      carYear: carYear ?? this.carYear,
    );
  }

  // Helper method to get star display
  String get starsDisplay {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    
    String stars = '★' * fullStars;
    if (hasHalfStar) stars += '☆';
    
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
    stars += '☆' * emptyStars;
    
    return stars;
  }

  // Helper method to format the review date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}