import 'package:cloud_firestore/cloud_firestore.dart';

class RentRequest {
  final String id;
  final String carId;
  final String carName;
  final String carImageUrl;
  final String ownerId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final Map<String, dynamic> rentalPeriod;
  final double carRentalCost;
  final double totalExtraCharges;
  final double totalPrice;
  final double downPayment;
  final String status;
  final String bookingType;
  final Timestamp createdAt;
  final String notes;
  final List<Map<String, dynamic>> extraCharges;
  final String paymentMethod;
  final String? receiptImageUrl;
  final Map<String, dynamic>? deliveryAddress;
  final bool isPaid;
  final Map<String, dynamic> documents;

  RentRequest({
    required this.id,
    required this.carId,
    required this.carName,
    required this.carImageUrl,
    required this.ownerId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.rentalPeriod,
    required this.carRentalCost,
    required this.totalExtraCharges,
    required this.totalPrice,
    required this.downPayment,
    required this.status,
    required this.bookingType,
    required this.createdAt,
    required this.notes,
    required this.extraCharges,
    required this.paymentMethod,
    this.receiptImageUrl,
    this.deliveryAddress,
    required this.isPaid,
    required this.documents,
  });

  factory RentRequest.fromMap(Map<String, dynamic> data, String documentId) {
    return RentRequest(
      id: documentId,
      carId: data['carId'] ?? '',
      carName: data['carName'] ?? '',
      carImageUrl: data['carImageUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      rentalPeriod: data['rentalPeriod'] ?? {},
      carRentalCost: (data['carRentalCost'] ?? 0).toDouble(),
      totalExtraCharges: (data['totalExtraCharges'] ?? 0).toDouble(),
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      downPayment: (data['downPayment'] ?? 0).toDouble(),
      status: data['status'] ?? '',
      bookingType: data['bookingType'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      notes: data['notes'] ?? '',
      extraCharges: List<Map<String, dynamic>>.from(data['extraCharges'] ?? []),
      paymentMethod: data['paymentMethod'] ?? '',
      receiptImageUrl: data['receiptImageUrl'],
      deliveryAddress: data['deliveryAddress'],
      isPaid: data['isPaid'] ?? false,
      documents: data['documents'] ?? {},
    );
  }
}