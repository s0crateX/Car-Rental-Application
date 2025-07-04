import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/Final Model/Firebase_car_model.dart';
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

  // Helper method to safely parse coordinate values
  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> _loadDistance() async {
    setState(() {
      _isLoadingDistance = true;
    });

    try {
      // Get car location from the car model
      final locMap = widget.car.location;
      LatLng? carLoc;

      // Check if the car location has valid coordinates
      // Firebase stores location as 'lat' and 'lng'
      if (locMap.isNotEmpty) {
        if (locMap.containsKey('lat') && locMap.containsKey('lng')) {
          carLoc = LatLng(locMap['lat']!, locMap['lng']!);
        } else if (locMap.containsKey('latitude') &&
            locMap.containsKey('longitude')) {
          // Fallback for backward compatibility
          carLoc = LatLng(locMap['latitude']!, locMap['longitude']!);
        }
      }

      // Get user location from AuthService
      final authService = Provider.of<AuthService>(context, listen: false);
      final userData = authService.userData;
      LatLng? userLoc;

      // Check if user data contains location information
      if (userData != null) {
        Map<dynamic, dynamic>? locData;

        // Try different possible location field names
        if (userData.containsKey('location')) {
          locData = userData['location'] as Map?;
        } else if (userData.containsKey('userLocation')) {
          locData = userData['userLocation'] as Map?;
        }

        if (locData != null) {
          // Try different possible coordinate field names
          double? latitude;
          double? longitude;

          // User location uses 'latitude' and 'longitude' as seen in the Firebase screenshot
          if (locData.containsKey('latitude') &&
              locData.containsKey('longitude')) {
            latitude = _parseCoordinate(locData['latitude']);
            longitude = _parseCoordinate(locData['longitude']);
          }
          // Fallback to check for lat/lng format
          else if (locData.containsKey('lat') && locData.containsKey('lng')) {
            latitude = _parseCoordinate(locData['lat']);
            longitude = _parseCoordinate(locData['lng']);
          }

          // Create LatLng object if both coordinates are available
          if (latitude != null && longitude != null) {
            userLoc = LatLng(latitude, longitude);
            print('User location found: $latitude, $longitude');
          }
        }
      }

      // If either location is missing, show N/A
      if (carLoc == null || userLoc == null) {
        setState(() {
          _distanceText = 'N/A';
          _isLoadingDistance = false;
        });
        return;
      }

      // Calculate distance between user and car
      final distanceMeters = Distance().as(LengthUnit.Meter, userLoc, carLoc);
      final distanceKm = distanceMeters / 1000.0;

      // Format distance text based on distance
      setState(() {
        if (distanceKm < 1) {
          _distanceText = '${distanceMeters.toStringAsFixed(0)} m';
        } else {
          _distanceText = '${distanceKm.toStringAsFixed(2)} km';
        }
        _isLoadingDistance = false;
      });
    } catch (e) {
      print('Error calculating distance: $e');
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
              child: Image.network(
                widget.car.image,
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
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
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                              fontSize: 20,
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
