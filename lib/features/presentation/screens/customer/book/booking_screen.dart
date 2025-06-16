import 'package:flutter/material.dart';
import '../../../../../shared/data/sample_cars.dart';
import '../../../../../shared/models/car_model.dart';
import 'widgets/current_rental_widget.dart';
import 'widgets/rental_history_widget.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data: The first car is the current rental, the rest are history
    final List<CarModel> allCars = SampleCars.getPopularCars();
    final CarModel? currentRental = allCars.isNotEmpty ? allCars.first : null;
    final List<CarModel> rentalHistory =
        allCars.length > 1 ? allCars.sublist(1) : [];
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentRental != null) ...[
                Text(
                  'Currently Renting',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CurrentRentalWidget(car: currentRental),
                const SizedBox(height: 24),
              ],
              Text(
                'Rental History',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              RentalHistoryWidget(history: rentalHistory),
            ],
          ),
        ),
      ),
    );
  }
}
