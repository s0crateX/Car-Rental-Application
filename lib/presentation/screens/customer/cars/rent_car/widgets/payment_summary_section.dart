import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:car_rental_app/models/Firebase_car_model.dart';
import 'package:car_rental_app/config/theme.dart';

class PaymentSummarySection extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final CarModel car;
  final Map<String, bool> selectedExtras;
  final double deliveryCharge;

  const PaymentSummarySection({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.car,
    required this.selectedExtras,
    required this.deliveryCharge,
  });

  // Helper method to build section titles with consistent styling
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  // Helper method to create peso icon with amount
  Widget _buildPesoAmount(String amount, {TextStyle? textStyle, Color? iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/svg/peso.svg',
          width: 16,
          height: 16,
          colorFilter: ColorFilter.mode(
            iconColor ?? AppTheme.white,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            amount,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (startDate == null ||
        endDate == null ||
        endDate!.isBefore(startDate!)) {
      return const SizedBox.shrink(); // Don't show if dates are invalid
    }

    final duration = endDate!.difference(startDate!);
    final totalHours = duration.inHours > 0 ? duration.inHours : 0;
    final totalDays = duration.inDays;
    final remainingHours = totalHours % 24;

    // Calculate rental cost with discount
    double carRentalCost = totalHours * car.hourlyRate;
    double discountPercentage = 0.0;
    String discountType = '';
    
    // Apply discounts based on rental duration
    if (totalHours >= 720) { // 30 days (1 month)
      discountPercentage = car.discounts['1month'] ?? 0.0;
      discountType = '1 Month Discount';
    } else if (totalHours >= 168) { // 7 days (1 week)
      discountPercentage = car.discounts['1week'] ?? 0.0;
      discountType = '1 Week Discount';
    } else if (totalHours >= 72) { // 3 days
      discountPercentage = car.discounts['3days'] ?? 0.0;
      discountType = '3 Days Discount';
    }
    
    final originalCarRentalCost = carRentalCost;
    final discountAmount = carRentalCost * (discountPercentage / 100);
    carRentalCost = carRentalCost - discountAmount;
    
    final downPayment = carRentalCost * 0.5; // 50% of discounted car rental cost

    double totalExtraCharges = 0;
    selectedExtras.forEach((name, isSelected) {
      if (isSelected) {
        final chargeData = car.extraCharges.firstWhere(
          (c) => c['name'] == name,
          orElse: () => {'name': name, 'amount': '0.0'},
        );
        final price =
            double.tryParse(chargeData['amount']?.toString() ?? '0') ?? 0.0;
        totalExtraCharges += price;
      }
    });

    final double grandTotal =
        carRentalCost + totalExtraCharges + deliveryCharge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Payment Summary', context),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.navy,
            border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Car Rental (${totalDays}d ${remainingHours}h / ${totalHours}h total)',
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (discountPercentage > 0) ...[
                           _buildPesoAmount(
                             originalCarRentalCost.toStringAsFixed(2),
                             textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                               decoration: TextDecoration.lineThrough,
                               color: AppTheme.lightBlue.withOpacity(0.6),
                             ),
                             iconColor: AppTheme.lightBlue.withOpacity(0.6),
                           ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.green,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${discountPercentage.toStringAsFixed(0)}% OFF',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                           _buildPesoAmount(
                             carRentalCost.toStringAsFixed(2),
                             textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                         ] else
                           _buildPesoAmount(
                             carRentalCost.toStringAsFixed(2),
                             textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${startDate!.day}/${startDate!.month}/${startDate!.year} ${startDate!.hour}:${startDate!.minute.toString().padLeft(2, '0')} - ${endDate!.day}/${endDate!.month}/${endDate!.year} ${endDate!.hour}:${endDate!.minute.toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                     flex: 1,
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         SvgPicture.asset(
                           'assets/svg/peso.svg',
                           width: 12,
                           height: 12,
                           colorFilter: ColorFilter.mode(
                             AppTheme.paleBlue,
                             BlendMode.srcIn,
                           ),
                         ),
                         Flexible(
                           child: Text(
                             '${car.hourlyRate.toStringAsFixed(2)}/hour',
                             style: Theme.of(context).textTheme.bodySmall,
                             overflow: TextOverflow.ellipsis,
                             maxLines: 1,
                           ),
                         ),
                       ],
                     ),
                   ),
                ],
              ),
              if (discountPercentage > 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        discountType,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.green,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '-',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SvgPicture.asset(
                          'assets/svg/peso.svg',
                          width: 14,
                          height: 14,
                          colorFilter: ColorFilter.mode(
                            AppTheme.green,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          discountAmount.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              if (totalExtraCharges > 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Extra Charges',
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPesoAmount(
                       totalExtraCharges.toStringAsFixed(2),
                       textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                  ],
                ),
              ],
              if (deliveryCharge > 0) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Delivery Charge',
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildPesoAmount(
                       deliveryCharge.toStringAsFixed(2),
                       textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                  ],
                ),
              ],
              Divider(
                height: 32,
                color: AppTheme.lightBlue.withOpacity(0.3),
                thickness: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Total Payment',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPesoAmount(
                     grandTotal.toStringAsFixed(2),
                     textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: AppTheme.lightBlue,
                     ),
                     iconColor: AppTheme.lightBlue,
                   ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Down Payment (50%)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPesoAmount(
                     downPayment.toStringAsFixed(2),
                     textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                       fontWeight: FontWeight.w600,
                       color: AppTheme.mediumBlue,
                     ),
                     iconColor: AppTheme.mediumBlue,
                   ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'A 50% down payment is required to confirm the booking, excluding extra charges. The remaining balance, along with any applicable extra charges, must be paid upon return of the vehicle. Additional fees may apply for late returns or based on the condition and usage of the vehicle.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.4,
                ),
                textAlign: TextAlign.justify,
                softWrap: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
