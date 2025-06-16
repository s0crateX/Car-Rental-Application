import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/car_model.dart';
import 'blinking_status_indicator.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:latlong2/latlong.dart';

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
    final carLoc = widget.car.location;
    final userData = Provider.of<AuthService>(context, listen: false).userData;
    LatLng? userLoc;
    final locData = userData != null ? userData['location'] : null;
    if (locData != null && locData is Map) {
      final lat = locData['latitude'];
      final lng = locData['longitude'];
      if (lat != null && lng != null) {
        userLoc = LatLng(lat.toDouble(), lng.toDouble());
      }
    }
    if (carLoc == null || userLoc == null) {
      setState(() {
        _distanceText = 'N/A';
        _isLoadingDistance = false;
      });
      return;
    }
    setState(() {
      _isLoadingDistance = true;
    });
    try {
      final distanceMeters = Distance().as(LengthUnit.Meter, userLoc, carLoc);
      final distanceKm = distanceMeters / 1000.0;
      setState(() {
        _distanceText = distanceKm < 1
            ? '${(distanceMeters).toStringAsFixed(0)} m'
            : '${distanceKm.toStringAsFixed(2)} km';
        _isLoadingDistance = false;
      });
    } catch (e) {
      setState(() {
        _distanceText = 'N/A';
        _isLoadingDistance = false;
      });
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
                        _isLoadingDistance
                            ? SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : Text(
                                _distanceText ?? 'Calculating...',
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
