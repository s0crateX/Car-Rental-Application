import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String? id;
  final String? name;
  final String? imageUrl;
  final double? rentalCost;

  Vehicle({this.id, this.name, this.imageUrl, this.rentalCost});

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      name: map['name'],
      imageUrl: map['imageUrl'],
      rentalCost:
          map['rentalCost'] is double
              ? map['rentalCost']
              : (map['rentalCost'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'rentalCost': rentalCost,
    };
  }
}

class DeliveryAddress {
  final String? address;
  final double? latitude;
  final double? longitude;

  DeliveryAddress({this.address, this.latitude, this.longitude});

  factory DeliveryAddress.fromMap(Map<String, dynamic>? map) {
    if (map == null) return DeliveryAddress();

    return DeliveryAddress(
      address: map['address'],
      latitude:
          map['latitude'] is double
              ? map['latitude']
              : (map['latitude'] as num?)?.toDouble(),
      longitude:
          map['longitude'] is double
              ? map['longitude']
              : (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'address': address, 'latitude': latitude, 'longitude': longitude};
  }
}

class RentalDocuments {
  final String? id;
  final String? license;

  RentalDocuments({this.id, this.license});

  factory RentalDocuments.fromMap(Map<String, dynamic>? map) {
    if (map == null) return RentalDocuments();

    return RentalDocuments(id: map['id'], license: map['license']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'license': license};
  }
}

class ExtraCharges {
  final bool? isPaid;
  final String? notes;
  final double? amount;

  ExtraCharges({this.isPaid, this.notes, this.amount});

  factory ExtraCharges.fromMap(Map<String, dynamic>? map) {
    if (map == null) return ExtraCharges();

    return ExtraCharges(
      isPaid: map['isPaid'] as bool? ?? false,
      notes: map['notes'],
      amount:
          map['amount'] is double
              ? map['amount']
              : (map['amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'isPaid': isPaid, 'notes': notes, 'amount': amount};
  }
}

class RentalPeriod {
  final int? days;
  final int? hours;
  final DateTime? startDate;
  final DateTime? endDate;

  RentalPeriod({this.days, this.hours, this.startDate, this.endDate});

  factory RentalPeriod.fromMap(Map<String, dynamic>? map) {
    print('RentalPeriod.fromMap received data: $map');
    if (map == null) {
      print('Warning: RentalPeriod.fromMap received a null map.');
      return RentalPeriod();
    }

    return RentalPeriod(
      days: map['days'] as int?,
      hours: map['hours'] as int?,
      startDate:
          map['startDate'] is Timestamp
              ? (map['startDate'] as Timestamp).toDate()
              : map['startDate'] is DateTime
                  ? map['startDate']
                  : null,
      endDate:
          map['endDate'] is Timestamp
              ? (map['endDate'] as Timestamp).toDate()
              : map['endDate'] is DateTime
                  ? map['endDate']
                  : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {'days': days, 'hours': hours, 'startDate': startDate, 'endDate': endDate};
  }
}
