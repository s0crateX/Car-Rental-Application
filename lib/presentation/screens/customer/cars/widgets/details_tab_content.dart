import 'package:flutter/material.dart';
import '../../../../../shared/models/Final Model/Firebase_car_model.dart';
import 'extra_charge_item.dart';
import 'pricing_option.dart';
import 'rental_details_item.dart';
import 'rental_requirement_item.dart';
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

            // Inclusions
            sectionTitleBuilder('Inclusions'),
            const SizedBox(height: 12),
            _buildInclusions(context),
            const SizedBox(height: 16),

            // Extra Charges
            sectionTitleBuilder('Extra Charges'),
            const SizedBox(height: 12),
            _buildExtraCharges(context),
            const SizedBox(height: 16),

            // Rental Requirements
            sectionTitleBuilder('Rental Requirements'),
            const SizedBox(height: 12),
            _buildRentalRequirements(),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 6 hours pricing
          if (car.price6h != '0' && car.price6h != '')
            PricingOption(
              period: '6 Hours',
              price: double.tryParse(car.price6h) ?? 0,
              onTap: () {
                // Handle selection - could navigate to booking screen with selected period
              },
            ),
          // 12 hours pricing
          if (car.price12h != '0' && car.price12h != '')
            PricingOption(
              period: '12 Hours',
              price: double.tryParse(car.price12h) ?? 0,
              onTap: () {
                // Handle 12-hour selection
              },
            ),
          // Daily pricing - recommended option
          if (car.price1d != '0' && car.price1d != '')
            PricingOption(
              period: 'Daily',
              price: double.tryParse(car.price1d) ?? 0,
              isRecommended: true,
              onTap: () {
                // Handle daily selection
              },
            ),
          // Weekly pricing
          if (car.price1w != '0' && car.price1w != '')
            PricingOption(
              period: 'Weekly',
              price: double.tryParse(car.price1w) ?? 0,
              onTap: () {
                // Handle weekly selection
              },
            ),
          // Monthly pricing
          if (car.price1m != '0' && car.price1m != '')
            PricingOption(
              period: 'Monthly',
              price: double.tryParse(car.price1m) ?? 0,
              onTap: () {
                // Handle monthly selection
              },
            ),
        ],
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

  Widget _buildInclusions(BuildContext context) {
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
            final amount =
                double.tryParse(
                  charge['price']?.toString() ??
                      charge['amount']?.toString() ??
                      '0',
                ) ??
                0.0;
            final unit = charge['unit'] as String?;

            return ExtraChargeItem(title: title, amount: amount, unit: unit);
          }).toList(),
    );
  }

  Widget _buildRentalRequirements() {
    // Since Firebase model doesn't have rental requirements, we'll show some standard ones
    return Column(
      children: [
        RentalRequirementItem(
          title: "Driver's License",
          requirement: 'Valid driver\'s license required',
        ),
        RentalRequirementItem(
          title: 'Age',
          requirement: 'Driver must be at least 21 years old',
        ),
        RentalRequirementItem(
          title: 'Payment',
          requirement: 'Credit card or debit card required for payment',
        ),
        RentalRequirementItem(
          title: 'Security Deposit',
          requirement: 'Refundable security deposit may be required',
        ),
      ],
    );
  }
}
