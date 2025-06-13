import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/car_model.dart';
import '../utils/location_utils.dart';

class CarCardCompact extends StatefulWidget {
  final CarModel car;
  final VoidCallback? onBookNow;
  final VoidCallback? onFavorite;
  final VoidCallback? onTap;

  const CarCardCompact({
    super.key,
    required this.car,
    this.onBookNow,
    this.onFavorite,
    this.onTap,
  });

  @override
  State<CarCardCompact> createState() => _CarCardCompactState();

}

class _CarCardCompactState extends State<CarCardCompact> {
  String? _distanceText;
  bool _isLoadingDistance = false;

  @override
  void initState() {
    super.initState();
    _loadDistance();
  }

  Future<void> _loadDistance() async {
    if (widget.car.location == null) return;
    
    setState(() {
      _isLoadingDistance = true;
    });

    try {
      final distance = await LocationUtils().getDistanceToCarInKm(widget.car.location);
      if (mounted) {
        setState(() {
          _distanceText = LocationUtils().formatDistance(distance);
          _isLoadingDistance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDistance = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
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
              child: Image.asset(
                widget.car.image,
                width: double.infinity,
                height: 80,
                fit: BoxFit.cover,
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
                        child: Text(
                          widget.car.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onFavorite,
                        child: SvgPicture.asset(
                          widget.car.isFavorite
                              ? 'assets/svg/heart-filled.svg'
                              : 'assets/svg/heart.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            widget.car.isFavorite
                                ? Colors.red
                                : theme.colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/star-filled.svg',
                        width: 12,
                        height: 12,
                        colorFilter: const ColorFilter.mode(
                          Colors.amber,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.car.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.car.type,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.car.location != null) ...[  
                        const SizedBox(width: 4),
                        _isLoadingDistance
                            ? SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : Row(
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
                                    _distanceText ?? 'Calculating...',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                      ],
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
                              widget.car.transmissionType.toLowerCase().contains('manual')
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
                              child: Text(
                                widget.car.transmissionType,
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
                      SizedBox(width: 4),
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
                              child: Text(
                                widget.car.fuelType,
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
                      SizedBox(width: 4),
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
                                widget.car.seatsCount,
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
                  const SizedBox(height: 15), // Reduced from 8 to 6
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Added for better alignment
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svg/peso.svg',
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.car.price.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            widget.car.pricePeriod,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: widget.onBookNow,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ), // Slightly increased padding
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Rent', // Changed from 'Book' to 'Rent'
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
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
