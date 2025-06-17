import 'car_model.dart';

enum BookingStatus { pending, approved, completed, cancelled }

class BookingModel {
  final String id;
  final CarModel car;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final Map<String, double> extras; // e.g., {'Driver Fee': 25.0}
  final BookingStatus status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.extras,
    required this.status,
    required this.createdAt,
  });
}
