class CarBrandModel {
  final String name;
  final String logo;
  final int count;

  const CarBrandModel({
    required this.name,
    required this.logo,
    required this.count,
  });

  // Factory constructor to create CarBrandModel from a Map
  factory CarBrandModel.fromMap(Map<String, dynamic> map) {
    return CarBrandModel(
      name: map['name'] ?? '',
      logo: map['image'] ?? '',
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': logo,
      'count': count,
    };
  }
}
