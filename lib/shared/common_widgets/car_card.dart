import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/Final Model/Firebase_car_model.dart';
import 'blinking_status_indicator.dart';


class CarCard extends StatelessWidget {
  final CarModel car;
  final double? distanceInMeters;
  final VoidCallback? onBookNow;
  final VoidCallback? onFavorite;
  final VoidCallback? onTap;

  const CarCard({
    super.key,
    required this.car,
    this.distanceInMeters,
    this.onBookNow,
    this.onFavorite,
    this.onTap,
  });

  String _formatDistance(double? distance) {
    if (distance == null || distance.isInfinite) return 'N/A';
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distanceText = _formatDistance(distanceInMeters);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: car.image.startsWith('http') || car.image.startsWith('https')
                    ? Image.network(
                      car.image,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 180,
                          color: Colors.grey[300],
                          child: Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.car_rental,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    )
                    : Image.asset(
                      car.image,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.car_rental,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ),
                // Status indicator
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      BlinkingStatusIndicator(
                        isAvailable:
                            car.availabilityStatus ==
                            AvailabilityStatus.available,
                        size: 8,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        car.availabilityStatus ==
                                AvailabilityStatus.available
                            ? 'Available'
                            : 'Unavailable',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color:
                              car.availabilityStatus ==
                                      AvailabilityStatus.available
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${car.brand} ${car.model}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    car.type,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFeatureItem(
                        context,
                        car.transmissionType.toLowerCase().contains(
                              'manual',
                            )
                            ? 'assets/svg/manual-transmission.svg'
                            : 'assets/svg/automatic-transmission.svg',
                        car.transmissionType,
                      ),
                      _buildFeatureItem(
                        context,
                        'assets/svg/gas-station.svg',
                        car.fuelType,
                      ),
                      _buildFeatureItem(
                        context,
                        'assets/svg/user.svg',
                        car.seatsCount,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Extra Charges Section
                  if (car.extraCharges.isNotEmpty) ...[  
                    Text(
                      'Extra Charges',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...car.extraCharges.map((charge) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            charge['name']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '₱${charge['amount']?.toString() ?? '0'}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/peso.svg',
                            width: 18,
                            height: 18,
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            car.price.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            car.pricePeriod,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svg/location.svg',
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            distanceText,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (onBookNow != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: car.availabilityStatus == AvailabilityStatus.available ? onBookNow : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.3),
                            disabledForegroundColor: theme.colorScheme.onPrimary.withOpacity(0.7),
                          ),
                          child: Text(
                            car.availabilityStatus == AvailabilityStatus.available ? 'Book Now' : 'Not Available',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String svgAsset, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SvgPicture.asset(
          svgAsset,
          width: 16,
          height: 16,
          colorFilter: ColorFilter.mode(
            theme.colorScheme.onSurface.withOpacity(0.7),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
