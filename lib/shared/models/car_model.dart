class CarModel {
  final String id;
  final String image;
  final String type;
  final String name;
  final String transmissionType;
  final String fuelType;
  final String seatsCount;
  final double rating;
  final double price;
  final String pricePeriod;
  final bool isFavorite;

  CarModel({
    required this.id,
    required this.image,
    required this.type,
    required this.name,
    required this.transmissionType,
    required this.fuelType,
    required this.seatsCount,
    required this.rating,
    required this.price,
    this.pricePeriod = '/hr',
    this.isFavorite = false,
  });

  // Factory constructor to create a CarModel from a Map (for Firebase)
  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      id: map['id'] ?? '',
      image: map['image'] ?? '',
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      transmissionType: map['transmissionType'] ?? '',
      fuelType: map['fuelType'] ?? '',
      seatsCount: map['seatsCount'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      price: (map['price'] ?? 0.0).toDouble(),
      pricePeriod: map['pricePeriod'] ?? '/hr',
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  // Convert CarModel to a Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'type': type,
      'name': name,
      'transmissionType': transmissionType,
      'fuelType': fuelType,
      'seatsCount': seatsCount,
      'rating': rating,
      'price': price,
      'pricePeriod': pricePeriod,
      'isFavorite': isFavorite,
    };
  }

  // Create a copy of the car model with updated fields
  CarModel copyWith({
    String? id,
    String? image,
    String? type,
    String? name,
    String? transmissionType,
    String? fuelType,
    String? seatsCount,
    double? rating,
    double? price,
    String? pricePeriod,
    bool? isFavorite,
  }) {
    return CarModel(
      id: id ?? this.id,
      image: image ?? this.image,
      type: type ?? this.type,
      name: name ?? this.name,
      transmissionType: transmissionType ?? this.transmissionType,
      fuelType: fuelType ?? this.fuelType,
      seatsCount: seatsCount ?? this.seatsCount,
      rating: rating ?? this.rating,
      price: price ?? this.price,
      pricePeriod: pricePeriod ?? this.pricePeriod,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
