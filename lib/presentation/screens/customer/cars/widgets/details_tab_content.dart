import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';
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
          // 6 hours pricing
          if (car.price6h != '0')
            PricingOption(
              period: '6 Hours',
              price: _buildPriceWidget(context, double.tryParse(car.price6h) ?? 0),
            ),
          if (car.price6h != '0') const Divider(),
          
          // 12 hours pricing
          if (car.price12h != '0')
            PricingOption(
              period: '12 Hours',
              price: _buildPriceWidget(context, double.tryParse(car.price12h) ?? 0),
            ),
          if (car.price12h != '0') const Divider(),
          
          // Daily pricing
          PricingOption(
            period: 'Daily',
            price: _buildPriceWidget(context, double.tryParse(car.price1d) ?? 0),
          ),
          const Divider(),
          
          // Weekly pricing
          if (car.price1w != '0')
            PricingOption(
              period: 'Weekly',
              price: _buildPriceWidget(context, double.tryParse(car.price1w) ?? 0),
            ),
          if (car.price1w != '0') const Divider(),
          
          // Monthly pricing
          if (car.price1m != '0')
            PricingOption(
              period: 'Monthly',
              price: _buildPriceWidget(context, double.tryParse(car.price1m) ?? 0),
            ),
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
          value:
              car.availabilityStatus == AvailabilityStatus.available
                  ? 'Available'
                  : car.availabilityStatus == AvailabilityStatus.rented
                      ? 'Rented'
                      : 'Under Maintenance',
        ),
        RentalDetailsItem(
          title: 'Location',
          value: car.address,
        ),
        RentalDetailsItem(
          title: 'Car Owner',
          value: car.carOwnerFullName,
        ),
        RentalDetailsItem(
          title: 'Year',
          value: car.year,
        ),
        RentalDetailsItem(
          title: 'Listed Date',
          value: formatDate(car.createdAt),
        ),
      ],
    );
  }

  Widget _buildInclusions(BuildContext context) {
    // Using features as inclusions since Firebase model doesn't have specific inclusions
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: car.features.map((feature) {
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
    return Column(
      children: car.extraCharges.map((charge) {
        final title = charge['title'] as String? ?? 'Additional Charge';
        final amount = double.tryParse(charge['amount']?.toString() ?? '0') ?? 0.0;
        
        return ExtraChargeItem(
          title: title,
          price: _buildPriceWidget(context, amount),
        );
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
