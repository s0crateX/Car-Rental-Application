import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/Firebase_car_model.dart';
import 'blinking_status_indicator.dart';

class CarCardCompact extends StatelessWidget {
  final CarModel car;
  final double? distanceInMeters;
  final VoidCallback? onBookNow;
  final VoidCallback? onFavorite;
  final VoidCallback? onTap;

  const CarCardCompact({
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
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  Image.network(
                    car.image,
                    width: double.infinity,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.car_rental,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                  // Rating overlay in top right corner
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/star-filled.svg',
                            width: 10,
                            height: 10,
                            colorFilter: const ColorFilter.mode(
                              Colors.amber,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            car.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${car.brand} ${car.model}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              car.type,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          BlinkingStatusIndicator(
                            isAvailable:
                                car.availabilityStatus ==
                                AvailabilityStatus.available,
                            size: 8,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            car.availabilityStatus ==
                                    AvailabilityStatus.available
                                ? 'Available'
                                : 'Unavailable',
                            style: TextStyle(
                              fontSize: 10,
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
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/location.svg',
                        width: 10,
                        height: 10,
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        distanceText,
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              car.transmissionType.toLowerCase().contains(
                                    'manual',
                                  )
                                  ? 'assets/svg/manual-gearbox.svg'
                                  : 'assets/svg/automatic-gearbox.svg',
                              width: 13,
                              height: 13,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.onSurface.withOpacity(0.7),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  car.transmissionType,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/gas-station.svg',
                              width: 13,
                              height: 13,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.onSurface.withOpacity(0.7),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  car.fuelType,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/user.svg',
                              width: 13,
                              height: 13,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.onSurface.withOpacity(0.7),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                car.seatsCount,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: SvgPicture.asset(
                              'assets/svg/peso.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const SizedBox(width: 1),
                          Text(
                            car.hourlyRate.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            ' / hour',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
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
                          const SizedBox(width: 2),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
