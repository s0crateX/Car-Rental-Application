class CarBrandModel {
  final String name;
  final String logo;

  CarBrandModel({
    required this.name,
    required this.logo,
  });

  factory CarBrandModel.fromMap(Map<String, dynamic> map) {
    return CarBrandModel(
      name: map['name'] ?? '',
      logo: map['logo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'logo': logo,
    };
  }
}
