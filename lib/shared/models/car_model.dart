import 'package:latlong2/latlong.dart';

class CarModel {
  final String id;
  final String image;
  final List<String> imageGallery; // Additional car images
  final String type; // Sedan, SUV, etc.
  final String name;
  final String brand; // Toyota, Honda, etc.
  final String model; // Vios, Civic, etc.
  final String year; // 2023, 2022, etc.
  final String transmissionType;
  final String fuelType;
  final String seatsCount;
  final String luggageCapacity; // e.g., "3 bags"
  final double rating;
  final double price;
  final String pricePeriod; // /hr, /day, /week, /month
  final Map<String, double> priceOptions; // Daily/Weekly/Monthly rates
  final bool isFavorite;
  final List<String> features; // AC, Bluetooth, USB port, etc.
  final List<String> inclusions; // Insurance, Unlimited Mileage, etc.
  final Map<String, double> extraCharges; // Driver fee, delivery fee, etc.
  final Map<String, double> discounts; // Early booking, long-term rental, etc.
  final DateTime availableFrom;
  final DateTime availableTo;
  final List<String> pickupLocations;
  final List<String> returnLocations;
  final Map<String, String> rentalRequirements; // License type, age, deposit
  final String fuelPolicy; // Full to Full, etc.
  final String cancellationPolicy; // Free cancellation, 24h notice, etc.
  final List<Map<String, dynamic>> reviews; // Customer reviews
  final LatLng? location; // Car's current location coordinates
  final String locationAddress; // Car's current location address

  CarModel({
    required this.id,
    required this.image,
    this.imageGallery = const [],
    required this.type,
    required this.name,
    this.brand = '',
    this.model = '',
    this.year = '',
    required this.transmissionType,
    required this.fuelType,
    required this.seatsCount,
    this.luggageCapacity = '',
    required this.rating,
    required this.price,
    this.pricePeriod = '/hr',
    this.priceOptions = const {},
    this.isFavorite = false,
    this.features = const [],
    this.inclusions = const [],
    this.extraCharges = const {},
    this.discounts = const {},
    DateTime? availableFrom,
    DateTime? availableTo,
    this.pickupLocations = const [],
    this.returnLocations = const [],
    this.rentalRequirements = const {},
    this.fuelPolicy = '',
    this.cancellationPolicy = '',
    this.reviews = const [],
    this.location,
    this.locationAddress = '',
  }) : availableFrom = availableFrom ?? DateTime.now(),
       availableTo =
           availableTo ?? DateTime.now().add(const Duration(days: 30));

  // Factory constructor to create a CarModel from a Map (for Firebase)
  factory CarModel.fromMap(Map<String, dynamic> map) {
    // Handle location data if available
    LatLng? location;
    if (map['location'] != null && 
        map['location']['latitude'] != null && 
        map['location']['longitude'] != null) {
      location = LatLng(
        map['location']['latitude'],
        map['location']['longitude'],
      );
    }
    
    return CarModel(
      id: map['id'] ?? '',
      image: map['image'] ?? '',
      imageGallery: List<String>.from(map['imageGallery'] ?? []),
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? '',
      transmissionType: map['transmissionType'] ?? '',
      fuelType: map['fuelType'] ?? '',
      seatsCount: map['seatsCount'] ?? '',
      luggageCapacity: map['luggageCapacity'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      price: (map['price'] ?? 0.0).toDouble(),
      pricePeriod: map['pricePeriod'] ?? '/hr',
      priceOptions: Map<String, double>.from(map['priceOptions'] ?? {}),
      isFavorite: map['isFavorite'] ?? false,
      features: List<String>.from(map['features'] ?? []),
      inclusions: List<String>.from(map['inclusions'] ?? []),
      extraCharges: Map<String, double>.from(map['extraCharges'] ?? {}),
      discounts: Map<String, double>.from(map['discounts'] ?? {}),
      availableFrom:
          map['availableFrom'] != null
              ? DateTime.parse(map['availableFrom'])
              : null,
      availableTo:
          map['availableTo'] != null
              ? DateTime.parse(map['availableTo'])
              : null,
      pickupLocations: List<String>.from(map['pickupLocations'] ?? []),
      returnLocations: List<String>.from(map['returnLocations'] ?? []),
      rentalRequirements: Map<String, String>.from(
        map['rentalRequirements'] ?? {},
      ),
      fuelPolicy: map['fuelPolicy'] ?? '',
      cancellationPolicy: map['cancellationPolicy'] ?? '',
      reviews:
          map['reviews'] != null
              ? List<Map<String, dynamic>>.from(map['reviews'])
              : [],
      location: location,
      locationAddress: map['locationAddress'] ?? '',
    );
  }

  // Convert CarModel to a Map (for Firebase)
  Map<String, dynamic> toMap() {
    // Create a map with all the existing fields
    final map = {
      'id': id,
      'image': image,
      'imageGallery': imageGallery,
      'type': type,
      'name': name,
      'brand': brand,
      'model': model,
      'year': year,
      'transmissionType': transmissionType,
      'fuelType': fuelType,
      'seatsCount': seatsCount,
      'luggageCapacity': luggageCapacity,
      'rating': rating,
      'price': price,
      'pricePeriod': pricePeriod,
      'priceOptions': priceOptions,
      'isFavorite': isFavorite,
      'features': features,
      'inclusions': inclusions,
      'extraCharges': extraCharges,
      'discounts': discounts,
      'availableFrom': availableFrom.toIso8601String(),
      'availableTo': availableTo.toIso8601String(),
      'pickupLocations': pickupLocations,
      'returnLocations': returnLocations,
      'rentalRequirements': rentalRequirements,
      'fuelPolicy': fuelPolicy,
      'cancellationPolicy': cancellationPolicy,
      'reviews': reviews,
      'locationAddress': locationAddress,
    };
    
    // Add location data if available
    if (location != null) {
      map['location'] = {
        'latitude': location!.latitude,
        'longitude': location!.longitude,
      };
    }
    
    return map;
  }

  // Create a copy of the car model with updated fields
  CarModel copyWith({
    String? id,
    String? image,
    List<String>? imageGallery,
    String? type,
    String? name,
    String? brand,
    String? model,
    String? year,
    String? transmissionType,
    String? fuelType,
    String? seatsCount,
    String? luggageCapacity,
    double? rating,
    double? price,
    String? pricePeriod,
    Map<String, double>? priceOptions,
    bool? isFavorite,
    List<String>? features,
    List<String>? inclusions,
    Map<String, double>? extraCharges,
    Map<String, double>? discounts,
    DateTime? availableFrom,
    DateTime? availableTo,
    List<String>? pickupLocations,
    List<String>? returnLocations,
    Map<String, String>? rentalRequirements,
    String? fuelPolicy,
    String? cancellationPolicy,
    List<Map<String, dynamic>>? reviews,
    LatLng? location,
    String? locationAddress,
  }) {
    return CarModel(
      id: id ?? this.id,
      image: image ?? this.image,
      imageGallery: imageGallery ?? this.imageGallery,
      type: type ?? this.type,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      transmissionType: transmissionType ?? this.transmissionType,
      fuelType: fuelType ?? this.fuelType,
      seatsCount: seatsCount ?? this.seatsCount,
      luggageCapacity: luggageCapacity ?? this.luggageCapacity,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      pricePeriod: pricePeriod ?? this.pricePeriod,
      priceOptions: priceOptions ?? this.priceOptions,
      isFavorite: isFavorite ?? this.isFavorite,
      features: features ?? this.features,
      inclusions: inclusions ?? this.inclusions,
      extraCharges: extraCharges ?? this.extraCharges,
      discounts: discounts ?? this.discounts,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      pickupLocations: pickupLocations ?? this.pickupLocations,
      returnLocations: returnLocations ?? this.returnLocations,
      rentalRequirements: rentalRequirements ?? this.rentalRequirements,
      fuelPolicy: fuelPolicy ?? this.fuelPolicy,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      reviews: reviews ?? this.reviews,
      location: location ?? this.location,
      locationAddress: locationAddress ?? this.locationAddress,
    );
  }
}
