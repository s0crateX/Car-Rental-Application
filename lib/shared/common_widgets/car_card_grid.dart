import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/Final Model/Firebase_car_model.dart';
import 'blinking_status_indicator.dart';

class CarCardGrid extends StatelessWidget {
  final CarModel car;
  final VoidCallback? onTap;
  final double? distanceInMeters;

  const CarCardGrid({
    super.key,
    required this.car,
    this.onTap,
    this.distanceInMeters,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildCarImage(), _buildDetailsSection(context)],
        ),
      ),
    );
  }

  Widget _buildCarImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Image.network(
        car.image,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 120,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder:
            (context, error, stackTrace) => Container(
              height: 120,
              color: Colors.grey[300],
              child: const Icon(
                Icons.directions_car,
                size: 40,
                color: Colors.grey,
              ),
            ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final theme = Theme.of(context);
    final isAvailable = car.availabilityStatus == AvailabilityStatus.available;
    final distanceText = _formatDistance(distanceInMeters);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface.withOpacity(0.9),
            theme.colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.brand} ${car.model}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      car.type,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Location moved to features row
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildAvailability(isAvailable, theme),
            ],
          ),

          const SizedBox(height: 12),
          _buildAllFeatures(context, distanceText),
          // Price footer removed
        ],
      ),
    );
  }

  Widget _buildAvailability(bool isAvailable, ThemeData theme) {
    return Row(
      children: [
        BlinkingStatusIndicator(isAvailable: isAvailable, size: 8),
        const SizedBox(width: 6),
        Text(
          isAvailable ? 'Available' : 'Rented',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isAvailable ? Colors.greenAccent : Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAllFeatures(BuildContext context, String distanceText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Location
          Expanded(
            child: _buildFeatureItem(
              context,
              'assets/svg/location.svg',
              distanceText,
              color: Colors.white70,
              iconSize: 12,
            ),
          ),
          const SizedBox(width: 2),
          // Transmission
          Expanded(
            child: _buildFeatureItem(
              context,
              'assets/svg/manual-gearbox.svg',
              car.transmissionType,
              color: Colors.white70,
              iconSize: 12,
            ),
          ),
          const SizedBox(width: 2),
          // Fuel type
          Expanded(
            child: _buildFeatureItem(
              context,
              'assets/svg/gas-station.svg',
              car.fuelType,
              color: Colors.white70,
              iconSize: 12,
            ),
          ),
          const SizedBox(width: 2),
          // Seats
          Expanded(
            child: _buildFeatureItem(
              context,
              'assets/svg/user.svg',
              '${car.seatsCount} seats',
              color: Colors.white70,
              iconSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // _buildFooter method removed as it's no longer needed

  String _formatDistance(double? distance) {
    if (distance == null || distance.isInfinite) return 'N/A';
    if (distance < 1000) {
      return '${distance.toStringAsFixed(2)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} km';
    }
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String svgAsset,
    String text, {
    Color color = Colors.white70,
    double iconSize = 14,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          svgAsset,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}
