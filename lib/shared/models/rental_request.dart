class RentalRequest {
  final String id;
  final String customerName;
  final String carName;
  final String carImage;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String deliveryPreference;
  final String status; // 'pending', 'approved', 'rejected'
  final double totalPrice;

  RentalRequest({
    required this.id,
    required this.customerName,
    required this.carName,
    required this.carImage,
    required this.pickupDate,
    required this.returnDate,
    required this.deliveryPreference,
    this.status = 'pending',
    required this.totalPrice,
  });

  int get rentalDurationInDays => returnDate.difference(pickupDate).inDays + 1;
}

// Sample data
final List<RentalRequest> sampleRentalRequests = [
  RentalRequest(
    id: 'REQ001',
    customerName: 'David Santos',
    carName: 'Hyundai Verna',
    carImage: 'assets/images/cars/1.png',
    pickupDate: DateTime.now().add(const Duration(days: 2)),
    returnDate: DateTime.now().add(const Duration(days: 5)),
    deliveryPreference: 'Door Delivery',
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
    deliveryPreference: 'Door Delivery',
    status: 'approved',
    totalPrice: 170.00,
  ),
];
