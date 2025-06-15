import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/car_model.dart';
import 'blinking_status_indicator.dart';
import '../utils/location_utils.dart';

class CarCard extends StatefulWidget {
  final CarModel car;
  final VoidCallback? onBookNow;
  final VoidCallback? onFavorite;

  const CarCard({
    super.key,
    required this.car,
    this.onBookNow,
    this.onFavorite,
  });

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {
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
      final distance = await LocationUtils().getDistanceToCarInKm(
        widget.car.location,
      );
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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
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
                child: Image.asset(
                  widget.car.image,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/star-filled.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Colors.amber,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.car.rating.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: widget.onFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Row(
                      children: [
                        BlinkingStatusIndicator(
                          isAvailable:
                              widget.car.availabilityStatus ==
                              AvailabilityStatus.available,
                          size: 8,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.car.availabilityStatus ==
                                  AvailabilityStatus.available
                              ? 'Available'
                              : 'Unavailable',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color:
                                widget.car.availabilityStatus ==
                                        AvailabilityStatus.available
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  children: [
                    Text(
                      widget.car.type,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    if (widget.car.location != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        height: 4,
                        width: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isLoadingDistance
                          ? SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                          : Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/location.svg',
                                width: 12,
                                height: 12,
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _distanceText ?? 'Calculating...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.car.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFeatureItem(
                      context,
                      widget.car.transmissionType.toLowerCase().contains(
                            'manual',
                          )
                          ? 'assets/svg/manual-gearbox.svg'
                          : 'assets/svg/automatic-gearbox.svg',
                      widget.car.transmissionType,
                    ),
                    _buildFeatureItem(
                      context,
                      'assets/svg/gas-station.svg',
                      widget.car.fuelType,
                    ),
                    _buildFeatureItem(
                      context,
                      'assets/svg/user.svg',
                      widget.car.seatsCount,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: SvgPicture.asset(
                              'assets/svg/peso.svg',
                              width: 18,
                              height: 18,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          TextSpan(
                            text: widget.car.price.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: widget.car.pricePeriod,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
