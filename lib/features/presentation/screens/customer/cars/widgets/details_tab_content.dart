import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../config/theme.dart';
import '../../../../../../shared/models/car_model.dart';
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
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          PricingOption(
            period: 'Hourly',
            price: _buildPriceWidget(context, car.price),
          ),
          const Divider(),
          ...car.priceOptions.entries.map((entry) {
            return PricingOption(
              period: entry.key,
              price: _buildPriceWidget(context, entry.value),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceWidget(BuildContext context, double price) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/svg/peso.svg',
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(
            Theme.of(context).primaryColor,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          price.toStringAsFixed(2),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRentalDetails() {
    return Column(
      children: [
        RentalDetailsItem(
          title: 'Availability',
          value: car.availabilityStatus == AvailabilityStatus.available ? 'Available' : 'Unavailable',
        ),
        RentalDetailsItem(
          title: 'Pickup Locations',
          value: car.pickupLocations.join(', '),
        ),
        RentalDetailsItem(
          title: 'Return Locations',
          value: car.returnLocations.join(', '),
        ),
        RentalDetailsItem(title: 'Fuel Policy', value: car.fuelPolicy),
        RentalDetailsItem(
          title: 'Cancellation Policy',
          value: car.cancellationPolicy,
        ),
      ],
    );
  }

  Widget _buildInclusions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            car.inclusions.map((inclusion) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Chip(
                  label: Text(inclusion),
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
    return Column(
      children:
          car.extraCharges.entries.map((entry) {
            return ExtraChargeItem(
              title: entry.key,
              price: _buildPriceWidget(context, entry.value),
            );
          }).toList(),
    );
  }

  Widget _buildRentalRequirements() {
    return Column(
      children:
          car.rentalRequirements.entries.map((entry) {
            return RentalRequirementItem(
              title: entry.key,
              requirement: entry.value,
            );
          }).toList(),
    );
  }
}
