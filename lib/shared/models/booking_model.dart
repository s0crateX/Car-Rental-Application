import 'car_model.dart';
import 'customer_model.dart';
import 'payment_method.dart';

enum BookingStatus { pending, approved, completed, cancelled }

class BookingModel {
  final String id;
  final CarModel car;
  final Customer customer;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final Map<String, double> extras; // e.g., {'Driver Fee': 25.0}
  final BookingStatus status;
  final DateTime createdAt;
  final String? deliveryLocation; // Address where the car should be delivered
  final String? notes; // Special notes from the customer
  final PaymentMethod? paymentMethod; // Payment method used
  final String? receiptImageUrl; // Uploaded receipt image

  BookingModel({
    required this.id,
    required this.car,
    required this.customer,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.extras,
    required this.status,
    required this.createdAt,
    this.deliveryLocation,
    this.notes,
    this.paymentMethod,
    this.receiptImageUrl,
  });

  BookingModel copyWith({
    String? id,
    CarModel? car,
    Customer? customer,
    DateTime? startDate,
    DateTime? endDate,
    double? totalAmount,
    Map<String, double>? extras,
    BookingStatus? status,
    DateTime? createdAt,
    String? deliveryLocation,
    String? notes,
    PaymentMethod? paymentMethod,
    String? receiptImageUrl,
  }) {
    return BookingModel(
      id: id ?? this.id,
      car: car ?? this.car,
      customer: customer ?? this.customer,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalAmount: totalAmount ?? this.totalAmount,
      extras: extras ?? Map.from(this.extras),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
    );
  }
}
