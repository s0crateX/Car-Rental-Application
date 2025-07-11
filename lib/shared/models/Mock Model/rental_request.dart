import 'package:car_rental_app/models/customer%20models/rent%20model/rent_model.dart';

// Sample data
final List<RentalRequest> sampleRentalRequests = [
  RentalRequest(
    id: 'REQ001',
    customerName: 'David Santos',
    carName: 'Hyundai Verna',
    carImage: 'assets/images/cars/1.png',
    pickupDate: DateTime.now().add(const Duration(days: 2)),
    returnDate: DateTime.now().add(const Duration(days: 5)),
    deliveryPreference: 'Deliver',
    status: 'pending',
    totalPrice: 150.00,
  ),
  RentalRequest(
    id: 'REQ002',
    customerName: 'Jane Cruz',
    carName: 'Toyota Innova',
    carImage: 'assets/images/cars/1.png',
    pickupDate: DateTime.now().add(const Duration(days: 3)),
    returnDate: DateTime.now().add(const Duration(days: 7)),
    deliveryPreference: 'Pickup',
    status: 'pending',
    totalPrice: 200.00,
  ),
  RentalRequest(
    id: 'REQ003',
    customerName: 'Michael Tan',
    carName: 'Honda City',
    carImage: 'assets/images/cars/hyundai_verna.png',
    pickupDate: DateTime.now().add(const Duration(days: 5)),
    returnDate: DateTime.now().add(const Duration(days: 10)),
    deliveryPreference: 'Deliver',
    status: 'approved',
    totalPrice: 170.00,
  ),
];
