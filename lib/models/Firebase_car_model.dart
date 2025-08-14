import 'package:cloud_firestore/cloud_firestore.dart';

enum AvailabilityStatus { available, rented, maintenance }

enum VerificationStatus { pending, approved, rejected, verified }

class CarModel {
  final String id; // Document ID from Firestore
  final String type;
  final String brand;
  final String model;
  final String image; // Keep for backward compatibility
  final List<String> imageGallery;
  final double hourlyRate;
  final double rating;
  final int reviewCount;
  final double deliveryCharge;
  final String seatsCount;
  final String luggageCapacity;
  final String transmissionType;
  final String fuelType;
  final String year;
  final AvailabilityStatus availabilityStatus;
  final String description;
  final String address;
  final String carOwnerDocumentId;
  final String carOwnerFullName;
  final DateTime createdAt;
  final List<String> features;
  final List<Map<String, dynamic>> extraCharges;
  final List<String> rentalRequirements;
  final Map<String, double> location;
  final List<String> orDocuments;  // Official Receipt documents
  final List<String> crDocuments;  // Certificate of Registration documents
  final List<String> issueImages;  // Car issue/damage photos
  final VerificationStatus verificationStatus;  // Admin verification status
  final Map<String, double> discounts;  // Rental period discounts (3days, 1week, 1month)

  CarModel({
    required this.id,
    required this.type,
    required this.brand,
    required this.model,
    required this.image,
    required this.imageGallery,
    required this.hourlyRate,
    required this.rating,
    required this.reviewCount,
    required this.deliveryCharge,
    required this.seatsCount,
    required this.luggageCapacity,
    required this.transmissionType,
    required this.fuelType,
    required this.year,
    required this.availabilityStatus,
    required this.description,
    required this.address,
    required this.carOwnerDocumentId,
    required this.carOwnerFullName,
    required this.createdAt,
    required this.features,
    required this.extraCharges,
    required this.rentalRequirements,
    required this.location,
    required this.orDocuments,
    required this.crDocuments,
    required this.issueImages,
    required this.verificationStatus,
    required this.discounts,
  });

  // Factory constructor to create CarModel from Firestore document
  factory CarModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarModel.fromMap(data, doc.id);
  }

  // Factory constructor to create CarModel from Map with optional document ID
  factory CarModel.fromMap(Map<String, dynamic> map, [String? documentId]) {
    return CarModel(
      id: documentId ?? map['carId'] ?? '',
      type: map['type'] ?? map['name'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      image: _getImageFromGallery(
        map,
      ), // Get first image from gallery as fallback
      imageGallery: _parseImageGallery(map['carImageGallery']),
      hourlyRate: (map['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      deliveryCharge: (map['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
      seatsCount: map['seats']?.toString() ?? '2',
      luggageCapacity: map['luggage']?.toString() ?? '1',
      transmissionType: map['transmissionType'] ?? 'Manual',
      fuelType: map['fuelType'] ?? 'Diesel',
      year: map['year']?.toString() ?? '2017',
      availabilityStatus: _parseAvailabilityStatus(map),
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      carOwnerDocumentId: map['carOwnerDocumentId'] ?? '',
      carOwnerFullName: map['carOwnerFullName'] ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      features: _parseFeatures(map['features']),
      extraCharges: _parseExtraCharges(map['extraCharges']),
      rentalRequirements: (map['rentalRequirements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: _parseLocation(map['location']),
      orDocuments: (map['orDocuments'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      crDocuments: (map['crDocuments'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      issueImages: (map['issueImages'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      verificationStatus: _parseVerificationStatus(map),
      discounts: _parseDiscounts(map['discounts']),
    );
  }

  // Convert CarModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'brand': brand,
      'model': model,
      'carImageGallery': imageGallery,
      'hourlyRate': hourlyRate,
      'rating': rating,
      'reviewCount': reviewCount,
      'deliveryCharge': deliveryCharge,
      'seats': seatsCount,
      'luggage': luggageCapacity,
      'transmissionType': transmissionType,
      'fuelType': fuelType,
      'year': year,
      'availabilityStatus': availabilityStatus.toString().split('.').last,
      'description': description,
      'address': address,
      'carOwnerDocumentId': carOwnerDocumentId,
      'carOwnerFullName': carOwnerFullName,
      'createdAt': Timestamp.fromDate(createdAt),
      'features': features,
      'rentalRequirements': rentalRequirements,
      'extraCharges': extraCharges,
      'location': location,
      'orDocuments': orDocuments,
      'crDocuments': crDocuments,
      'issueImages': issueImages,
      'verificationStatus': verificationStatus.toString().split('.').last,
      'discounts': discounts,
    };
  }

  // Helper methods for parsing data
  static List<String> _parseImageGallery(dynamic imageGallery) {
    if (imageGallery == null) return [];
    if (imageGallery is List) {
      return imageGallery.map((e) => e.toString()).toList();
    }
    return [];
  }

  static String _getImageFromGallery(Map<String, dynamic> map) {
    final gallery = _parseImageGallery(map['carImageGallery']);
    return gallery.isNotEmpty ? gallery.first : '';
  }

  static AvailabilityStatus _parseAvailabilityStatus(Map<String, dynamic> map) {
    // Since availability status is not in your current Firebase structure,
    // we'll default to available. You can add this field later.
    final status = map['availabilityStatus'] ?? map['status'] ?? 'available';
    switch (status.toString().toLowerCase()) {
      case 'rented':
        return AvailabilityStatus.rented;
      case 'maintenance':
        return AvailabilityStatus.maintenance;
      default:
        return AvailabilityStatus.available;
    }
  }
  
  static VerificationStatus _parseVerificationStatus(Map<String, dynamic> map) {
    final status = map['verificationStatus'] ?? 'pending';
    switch (status.toString().toLowerCase()) {
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      case 'verified':
        return VerificationStatus.verified;
      default:
        return VerificationStatus.pending;
    }
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is Timestamp) return dateTime.toDate();
    if (dateTime is String) {
      return DateTime.tryParse(dateTime) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static List<String> _parseFeatures(dynamic features) {
    if (features == null) return [];
    if (features is List) {
      return features.map((e) => e.toString()).toList();
    }
    return [];
  }

  static List<Map<String, dynamic>> _parseExtraCharges(dynamic extraCharges) {
    if (extraCharges == null) return [];
    if (extraCharges is List) {
      return extraCharges.map((e) {
        if (e is Map<String, dynamic>) return e;
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  static Map<String, double> _parseLocation(dynamic location) {
    if (location == null) return {};
    if (location is Map) {
      final result = <String, double>{};
      location.forEach((key, value) {
        if (value is num) {
          result[key.toString()] = value.toDouble();
        }
      });
      return result;
    }
    return {};
  }

  static Map<String, double> _parseDiscounts(dynamic discounts) {
    if (discounts == null) return {'3days': 0.0, '1week': 0.0, '1month': 0.0};
    if (discounts is Map) {
      final result = <String, double>{};
      // Set default values
      result['3days'] = 0.0;
      result['1week'] = 0.0;
      result['1month'] = 0.0;
      
      // Override with actual values if they exist
      discounts.forEach((key, value) {
        if (value is num) {
          result[key.toString()] = value.toDouble();
        }
      });
      return result;
    }
    return {'3days': 0.0, '1week': 0.0, '1month': 0.0};
  }

  // Copy with method for updates
  CarModel copyWith({
    String? id,
    String? type,
    String? brand,
    String? model,
    String? image,
    List<String>? imageGallery,
    double? hourlyRate,
    double? rating,
    int? reviewCount,
    double? deliveryCharge,
    String? seatsCount,
    String? luggageCapacity,
    String? transmissionType,
    String? fuelType,
    String? year,
    AvailabilityStatus? availabilityStatus,
    String? description,
    String? address,
    String? carOwnerDocumentId,
    String? carOwnerFullName,
    DateTime? createdAt,
    List<String>? features,
    List<String>? rentalRequirements,
    List<Map<String, dynamic>>? extraCharges,
    Map<String, double>? location,
    List<String>? orDocuments,
    List<String>? crDocuments,
    List<String>? issueImages,
    VerificationStatus? verificationStatus,
    Map<String, double>? discounts,
  }) {
    return CarModel(
      id: id ?? this.id,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      image: image ?? this.image,
      imageGallery: imageGallery ?? this.imageGallery,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      seatsCount: seatsCount ?? this.seatsCount,
      luggageCapacity: luggageCapacity ?? this.luggageCapacity,
      transmissionType: transmissionType ?? this.transmissionType,
      fuelType: fuelType ?? this.fuelType,
      year: year ?? this.year,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      description: description ?? this.description,
      address: address ?? this.address,
      carOwnerDocumentId: carOwnerDocumentId ?? this.carOwnerDocumentId,
      carOwnerFullName: carOwnerFullName ?? this.carOwnerFullName,
      createdAt: createdAt ?? this.createdAt,
      features: features ?? this.features,
      rentalRequirements: rentalRequirements ?? this.rentalRequirements,
      extraCharges: extraCharges ?? this.extraCharges,
      location: location ?? this.location,
      orDocuments: orDocuments ?? this.orDocuments,
      crDocuments: crDocuments ?? this.crDocuments,
      issueImages: issueImages ?? this.issueImages,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      discounts: discounts ?? this.discounts,
    );
  }
}
