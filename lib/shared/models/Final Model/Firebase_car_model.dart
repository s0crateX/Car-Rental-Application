import 'package:cloud_firestore/cloud_firestore.dart';

enum AvailabilityStatus { available, rented, maintenance }

class CarModel {
  final String id; // Document ID from Firestore
  final String name;
  final String brand;
  final String model;
  final String image; // Keep for backward compatibility
  final List<String> imageGallery;
  final double price;
  final String pricePeriod;
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
  final Map<String, double> location;

  // Pricing fields
  final String price12h;
  final String price1d;
  final String price1m;
  final String price1w;
  final String price6h;

  CarModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.image,
    required this.imageGallery,
    required this.price,
    required this.pricePeriod,
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
    required this.location,
    required this.price12h,
    required this.price1d,
    required this.price1m,
    required this.price1w,
    required this.price6h,
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
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      image: _getImageFromGallery(
        map,
      ), // Get first image from gallery as fallback
      imageGallery: _parseImageGallery(map['carImageGallery']),
      price: _parsePrice(map['price1d']), // Use 1-day price as default
      pricePeriod: '/day',
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
      location: _parseLocation(map['location']),
      price12h: map['price12h']?.toString() ?? '0',
      price1d: map['price1d']?.toString() ?? '0',
      price1m: map['price1m']?.toString() ?? '0',
      price1w: map['price1w']?.toString() ?? '0',
      price6h: map['price6h']?.toString() ?? '0',
    );
  }

  // Convert CarModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'model': model,
      'carImageGallery': imageGallery,
      'price12h': price12h,
      'price1d': price1d,
      'price1m': price1m,
      'price1w': price1w,
      'price6h': price6h,
      'seats': seatsCount,
      'luggage': luggageCapacity,
      'transmissionType': transmissionType,
      'fuelType': fuelType,
      'year': year,
      'description': description,
      'address': address,
      'carOwnerDocumentId': carOwnerDocumentId,
      'carOwnerFullName': carOwnerFullName,
      'createdAt': Timestamp.fromDate(createdAt),
      'features': features,
      'extraCharges': extraCharges,
      'location': location,
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

  static double _parsePrice(dynamic price) {
    if (price == null) return 0.0;
    if (price is num) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
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

  // Helper method to get formatted price based on period
  String getFormattedPrice(String period) {
    switch (period) {
      case '6h':
        return price6h;
      case '12h':
        return price12h;
      case '1d':
        return price1d;
      case '1w':
        return price1w;
      case '1m':
        return price1m;
      default:
        return price1d; // Default to daily price
    }
  }

  // Helper method to get price period display text
  String getPricePeriodDisplay(String period) {
    switch (period) {
      case '6h':
        return '/6hrs';
      case '12h':
        return '/12hrs';
      case '1d':
        return '/day';
      case '1w':
        return '/week';
      case '1m':
        return '/month';
      default:
        return '/day';
    }
  }

  // Copy with method for updates
  CarModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? image,
    List<String>? imageGallery,
    double? price,
    String? pricePeriod,
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
    List<Map<String, dynamic>>? extraCharges,
    Map<String, double>? location,
    String? price12h,
    String? price1d,
    String? price1m,
    String? price1w,
    String? price6h,
  }) {
    return CarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      image: image ?? this.image,
      imageGallery: imageGallery ?? this.imageGallery,
      price: price ?? this.price,
      pricePeriod: pricePeriod ?? this.pricePeriod,
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
      extraCharges: extraCharges ?? this.extraCharges,
      location: location ?? this.location,
      price12h: price12h ?? this.price12h,
      price1d: price1d ?? this.price1d,
      price1m: price1m ?? this.price1m,
      price1w: price1w ?? this.price1w,
      price6h: price6h ?? this.price6h,
    );
  }
}
