import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'vehicle.dart';

class ContractInfo {
  final String? url;
  final bool? signed;
  final String? signatureData;
  final List<Map<String, dynamic>>? signaturePoints;

  ContractInfo({
    this.url,
    this.signed,
    this.signatureData,
    this.signaturePoints,
  });

  factory ContractInfo.fromMap(Map<String, dynamic>? map) {
    if (map == null) return ContractInfo();
    
    return ContractInfo(
      url: map['url'],
      signed: map['signed'],
      signatureData: map['signatureData'],
      signaturePoints: map['signaturePoints'] is List
          ? List<Map<String, dynamic>>.from(map['signaturePoints'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'signed': signed,
      'signatureData': signatureData,
      'signaturePoints': signaturePoints,
    };
  }
}

class Rent {
  final String? id;
  final String? bookingType;
  final String? carId;
  final String? carName;
  final String? carImageUrl;
  final double? carRentalCost;
  final double? originalCarRentalCost;
  final double? discountPercentage;
  final double? discountAmount;
  final DateTime? createdAt;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final DeliveryAddress? deliveryAddress;
  final RentalDocuments? documents;
  final double? downPayment;
  final List<ExtraChargeItem>? extraCharges;
  final String? ownerId;
  final String? paymentMethod;
  final RentalPeriod? rentalPeriod;
  final String? status;
  final double? totalExtraCharges;
  final double? totalPrice;
  final String? notes;
  final String? receiptImageUrl;
  final Vehicle? vehicle;
  final ContractInfo? contract;

  Rent({
    this.id,
    this.bookingType,
    this.carId,
    this.carName,
    this.carImageUrl,
    this.carRentalCost,
    this.originalCarRentalCost,
    this.discountPercentage,
    this.discountAmount,
    this.createdAt,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    this.documents,
    this.downPayment,
    this.extraCharges,
    this.ownerId,
    this.paymentMethod,
    this.rentalPeriod,
    this.status,
    this.totalExtraCharges,
    this.totalPrice,
    this.notes,
    this.receiptImageUrl,
    this.vehicle,
    this.contract,
  });

  factory Rent.fromMap(Map<String, dynamic> map) {
    print('Rent.fromMap received data: $map');
    // Create vehicle from top-level car fields
    final vehicle = Vehicle(
      id: map['carId'],
      name: map['carName'],
      imageUrl: map['carImageUrl'],
      rentalCost: map['carRentalCost'] is double 
          ? map['carRentalCost'] 
          : (map['carRentalCost'] as num?)?.toDouble(),
    );

    return Rent(
      id: map['id'],
      bookingType: map['bookingType'],
      carId: map['carId'],
      carName: map['carName'],
      carImageUrl: map['carImageUrl'],
      carRentalCost: map['carRentalCost'] is double 
          ? map['carRentalCost'] 
          : (map['carRentalCost'] as num?)?.toDouble(),
      originalCarRentalCost: map['originalCarRentalCost'] is double 
          ? map['originalCarRentalCost'] 
          : (map['originalCarRentalCost'] as num?)?.toDouble(),
      discountPercentage: map['discountPercentage'] is double 
          ? map['discountPercentage'] 
          : (map['discountPercentage'] as num?)?.toDouble(),
      discountAmount: map['discountAmount'] is double 
          ? map['discountAmount'] 
          : (map['discountAmount'] as num?)?.toDouble(),
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
      customerId: map['customerId'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      deliveryAddress: DeliveryAddress.fromMap(
          map['deliveryAddress'] is Map ? Map<String, dynamic>.from(map['deliveryAddress']) : null),
      documents: RentalDocuments.fromMap(
          map['documents'] is Map ? Map<String, dynamic>.from(map['documents']) : null),
      downPayment: map['downPayment'] is double 
          ? map['downPayment'] 
          : (map['downPayment'] as num?)?.toDouble(),
      extraCharges: map['extraCharges'] is List
          ? (map['extraCharges'] as List)
              .map((item) => ExtraChargeItem.fromMap(Map<String, dynamic>.from(item)))
              .toList()
          : [],
      ownerId: map['ownerId'],
      paymentMethod: map['paymentMethod'],
      rentalPeriod: map['rentalPeriod'] != null
          ? RentalPeriod.fromMap(Map<String, dynamic>.from(map['rentalPeriod']))
          : null,
      status: map['status'] ?? 'PENDING',
      totalExtraCharges: map['totalExtraCharges'] is double 
          ? map['totalExtraCharges'] 
          : (map['totalExtraCharges'] as num?)?.toDouble(),
      totalPrice: map['totalPrice'] is double 
          ? map['totalPrice'] 
          : (map['totalPrice'] as num?)?.toDouble(),
      notes: map['notes'],
      receiptImageUrl: map['receiptImageUrl'],
      vehicle: vehicle,
      contract: map['contract'] != null
          ? ContractInfo.fromMap(Map<String, dynamic>.from(map['contract']))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingType': bookingType,
      'carId': carId,
      'carName': carName,
      'carImageUrl': carImageUrl,
      'carRentalCost': carRentalCost,
      'originalCarRentalCost': originalCarRentalCost,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'createdAt': createdAt,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress?.toMap(),
      'documents': documents?.toMap(),
      'downPayment': downPayment,
      'extraCharges': extraCharges?.map((item) => item.toMap()).toList(),
      'ownerId': ownerId,
      'paymentMethod': paymentMethod,
      'rentalPeriod': rentalPeriod?.toMap(),
      'status': status,
      'totalExtraCharges': totalExtraCharges,
      'totalPrice': totalPrice,
      'notes': notes,
      'receiptImageUrl': receiptImageUrl,
      'contract': contract?.toMap(),
    };
  }
  
  // Helper method to format date for display
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  // Helper method to format currency
  String formatCurrency(double? amount) {
    if (amount == null) return '₱0.00';
    return '₱${amount.toStringAsFixed(2)}';
  }
}
