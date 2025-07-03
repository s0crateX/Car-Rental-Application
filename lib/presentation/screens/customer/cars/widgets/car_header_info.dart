import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';
import '../../../../../shared/models/Final Model/Firebase_car_model.dart';
import 'car_location_map_screen.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:latlong2/latlong.dart';

class CarHeaderInfo extends StatefulWidget {
  final CarModel car;

  const CarHeaderInfo({super.key, required this.car});

  @override
  State<CarHeaderInfo> createState() => _CarHeaderInfoState();
}

class _CarHeaderInfoState extends State<CarHeaderInfo> {
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
      final carLocMap = widget.car.location;
      print('Car location data: $carLocMap');
      LatLng? carLoc;
      
      // Check if the car location has valid coordinates
      // Firebase stores location as 'lat' and 'lng'
      if (carLocMap.isNotEmpty) {
        if (carLocMap.containsKey('lat') && carLocMap.containsKey('lng')) {
          carLoc = LatLng(carLocMap['lat']!, carLocMap['lng']!);
        } else if (carLocMap.containsKey('latitude') && carLocMap.containsKey('longitude')) {
          // Fallback for backward compatibility
          carLoc = LatLng(carLocMap['latitude']!, carLocMap['longitude']!);
        }
      }
      
      // Get user location from AuthService
      final authService = Provider.of<AuthService>(context, listen: false);
      final userData = authService.userData;
      print('User data available: ${userData != null}');
      if (userData != null) {
        print('User data keys: ${userData.keys.toList()}');
        if (userData.containsKey('location')) {
          print('User location data: ${userData['location']}');
        }
      }
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
          if (locData.containsKey('latitude') && locData.containsKey('longitude')) {
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), // Reduced top padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Important: minimize column height
              children: [
                Text(
                  widget.car.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 28, // Slightly smaller font
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), // Reduced spacing
                Text(
                  '${widget.car.brand} ${widget.car.model} ${widget.car.year}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12, // Slightly smaller
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.car.location.isNotEmpty) ...[
                  const SizedBox(height: 10), // Reduced spacing
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/location.svg',
                        width: 14, // Slightly smaller icon
                        height: 14,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                          : Flexible(
                            child: Text(
                              _distanceText ?? 'Calculating...',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                    ],
                  ),
                  if (widget.car.address.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const SizedBox(width: 18), // Adjusted for smaller icon
                        Expanded(
                          child: Text(
                            widget.car.address,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                            maxLines: 1, // Reduced to 1 line to save space
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(
            width: 8,
          ), // Add some spacing between left and right content
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '₱${widget.car.price6h} / 6h',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.mediumBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.car.brand} • ${widget.car.transmissionType}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              if (widget.car.location.isNotEmpty) ...[
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => CarLocationMapScreen(car: widget.car),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(
                      5,
                    ), // Slightly smaller padding
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SvgPicture.asset(
                      'assets/svg/map-2.svg',
                      width: 35, // Smaller icon
                      height: 35,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
