import '../models/booking_model.dart';
import 'sample_cars.dart';
import 'sample_customers.dart';

class SampleBookings {
  static List<BookingModel> getSampleBookings() {
    final car = SampleCars.getPopularCars().first;
    return [
      BookingModel(
        id: 'B001',
        car: car,
        customer: SampleCustomers.getSampleCustomer1(),
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        totalAmount: 250.0,
        extras: {'Driver Fee': 25.0, 'Delivery Fee': 15.0},
        status: BookingStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        deliveryLocation: '1234 Sample Street, Makati City, Metro Manila',
        notes: 'Please ensure the car has a full tank of gas. I will need a child seat for my 3-year-old.',
      ),
      BookingModel(
        id: 'B002',
        car: car,
        customer: SampleCustomers.getSampleCustomer2(),
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
        totalAmount: 400.0,
        extras: {'Driver Fee': 25.0},
        status: BookingStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
        notes: 'Car was in good condition. No issues to report.',
        deliveryLocation: '5678 Sample Ave, Taguig City',
      ),
      BookingModel(
        id: 'B003',
        car: car,
        customer: SampleCustomers.getSampleCustomer3(),
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        totalAmount: 180.0,
        extras: {},
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
        notes: 'I would like to request early check-in if possible. Please confirm if the car will be available by 8 AM.',
        deliveryLocation: '9101 Sample Blvd, BGC, Taguig',
      ),
    ];
  }
}
