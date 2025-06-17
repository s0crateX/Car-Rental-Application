import '../models/booking_model.dart';
import 'sample_cars.dart';

class SampleBookings {
  static List<BookingModel> getSampleBookings() {
    final car = SampleCars.getPopularCars().first;
    return [
      BookingModel(
        id: 'B001',
        car: car,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        totalAmount: 250.0,
        extras: {'Driver Fee': 25.0, 'Delivery Fee': 15.0},
        status: BookingStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      BookingModel(
        id: 'B002',
        car: car,
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
        totalAmount: 400.0,
        extras: {'Driver Fee': 25.0},
        status: BookingStatus.completed,
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
      ),
      BookingModel(
        id: 'B003',
        car: car,
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        totalAmount: 180.0,
        extras: {},
        status: BookingStatus.pending,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
