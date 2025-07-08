import 'package:flutter/material.dart';
import '../../../../../shared/models/Final Model/Firebase_car_model.dart';
import 'extra_charge_item.dart';
import 'pricing_option.dart';
import 'rental_details_item.dart';
import 'spec_item.dart';

class DetailsTabContent extends StatelessWidget {
  final CarModel car;
  final String Function(DateTime) formatDate;
  final Widget Function(String) sectionTitleBuilder;

  const DetailsTabContent({
    super.key,
    required this.car,
    required this.formatDate,
    required this.sectionTitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Car Specifications
            sectionTitleBuilder('Car Specifications'),
            const SizedBox(height: 12),
            _buildSpecifications(context),
            const SizedBox(height: 16),

            // Pricing Options
            sectionTitleBuilder('Pricing Options'),
            const SizedBox(height: 12),
            _buildPricingOptions(context),
            const SizedBox(height: 16),

            // Rental Details
            sectionTitleBuilder('Rental Details'),
            const SizedBox(height: 12),
            _buildRentalDetails(),
            const SizedBox(height: 16),

            // Features
            sectionTitleBuilder('Features'),
            const SizedBox(height: 12),
            _buildFeatures(context),
            const SizedBox(height: 16),

            // Extra Charges
            sectionTitleBuilder('Extra Charges'),
            const SizedBox(height: 12),
            _buildExtraCharges(context),
            const SizedBox(height: 16),

            // Rental Requirements
            sectionTitleBuilder('Rental Requirements'),
            const SizedBox(height: 12),
            _buildRentalRequirements(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecifications(BuildContext context) {
    return Row(
      children: [
        SpecItem(svgAssetPath: 'assets/svg/seats.svg', text: car.seatsCount),
        SpecItem(
          svgAssetPath: 'assets/svg/luggage.svg',
          text: car.luggageCapacity,
        ),
        SpecItem(
          svgAssetPath: 'assets/svg/gas-station.svg',
          text: car.fuelType,
        ),
        SpecItem(
          svgAssetPath:
              car.transmissionType.toLowerCase().contains('auto')
                  ? 'assets/svg/automatic-gearbox.svg'
                  : car.transmissionType.toLowerCase().contains('manual')
                  ? 'assets/svg/manual-gearbox.svg'
                  : 'assets/svg/settings.svg',
          text: car.transmissionType,
        ),
      ],
    );
  }

  Widget _buildPricingOptions(BuildContext context) {
    if (car.hourlyRate <= 0) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Pricing not available for this vehicle.'),
        ),
      );
    }

    final pricingData = [
      {'period': '1 Hour', 'price': car.hourlyRate, 'isRecommended': false},
      {
        'period': '12 Hours',
        'price': car.hourlyRate * 12,
        'isRecommended': false,
      },
      {'period': 'Daily', 'price': car.hourlyRate * 24, 'isRecommended': true},
      {
        'period': 'Weekly',
        'price': car.hourlyRate * 24 * 7,
        'isRecommended': false,
      },
      {
        'period': 'Monthly',
        'price': car.hourlyRate * 24 * 30,
        'isRecommended': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children:
            pricingData.map((option) {
              return PricingOption(
                period: option['period'] as String,
                price: option['price'] as double,
                isRecommended: option['isRecommended'] as bool,
                onTap: () {
                  // Handle selection - could navigate to booking screen with selected period
                },
              );
            }).toList(),
      ),
    );
  }

  // _buildPriceWidget method removed as it's now handled by the PricingOption widget

  Widget _buildRentalDetails() {
    return Column(
      children: [
        RentalDetailsItem(title: 'Brand', value: car.brand),
        RentalDetailsItem(title: 'Year', value: car.year),
        RentalDetailsItem(
          title: 'Availability',
          value:
              car.availabilityStatus == AvailabilityStatus.available
                  ? 'Available'
                  : car.availabilityStatus == AvailabilityStatus.rented
                  ? 'Rented'
                  : 'Under Maintenance',
        ),
        RentalDetailsItem(title: 'Location', value: car.address),
        RentalDetailsItem(title: 'Car Owner', value: car.carOwnerFullName),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    // Using features as inclusions since Firebase model doesn't have specific inclusions
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            car.features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Chip(
                  label: Text(feature),
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildExtraCharges(BuildContext context) {
    if (car.extraCharges.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No extra charges for this vehicle'),
      );
    }

    return Column(
      children:
          car.extraCharges.map((charge) {
            final title =
                charge['name'] as String? ??
                charge['title'] as String? ??
                'Additional Charge';
            final amount = double.tryParse(charge['amount']?.toString() ?? '0') ?? 0.0;
            final unit = charge['unit'] as String?;

            return ExtraChargeItem(title: title, amount: amount, unit: unit);
          }).toList(),
    );
  }

  Widget _buildRentalRequirements(BuildContext context) {
    if (car.rentalRequirements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text('No rental requirements specified.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          car.rentalRequirements.map((requirement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      requirement,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
