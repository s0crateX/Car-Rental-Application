import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/Mock Model/car_model.dart';
import 'blinking_status_indicator.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:latlong2/latlong.dart';

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
        _distanceText =
            distanceKm < 1
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
                      Row(
                        children: [
                          BlinkingStatusIndicator(
                            isAvailable:
                                widget.car.availabilityStatus ==
                                AvailabilityStatus.available,
                            size: 8,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.car.availabilityStatus ==
                                    AvailabilityStatus.available
                                ? 'Available'
                                : 'Unavailable',
                            style: TextStyle(
                              fontSize: 10,
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
                              widget.car.transmissionType
                                      .toLowerCase()
                                      .contains('manual')
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
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            widget.car.pricePeriod,
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
      ),
    );
  }
}
