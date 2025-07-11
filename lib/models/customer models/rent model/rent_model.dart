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
