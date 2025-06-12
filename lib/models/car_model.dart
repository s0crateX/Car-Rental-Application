enum CarStatus {
  available,
  booked,
  unavailable
}

class Car {
  final String id;
  final String brand;
  final String model;
  final String variant;
  final int year;
  final double pricePerHour;
  final String imageUrl;
  final CarStatus status;
  final bool isNew;
  final String? bookingEndTime;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.variant,
    required this.year,
    required this.pricePerHour,
    required this.imageUrl,
    required this.status,
    this.isNew = false,
    this.bookingEndTime,
  });
}
