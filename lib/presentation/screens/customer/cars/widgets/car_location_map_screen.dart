import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import '../../../../../shared/models/Final Model/Firebase_car_model.dart';
import '../../../../../core/services/routing_service.dart';

class CarLocationMapScreen extends StatefulWidget {
  final CarModel car;
  const CarLocationMapScreen({super.key, required this.car});

  @override
  State<CarLocationMapScreen> createState() => _CarLocationMapScreenState();
}

class _CarLocationMapScreenState extends State<CarLocationMapScreen> {
  List<LatLng> _routePoints = [];
  bool _loadingRoute = false;
  String _routeError = '';

  @override
  void initState() {
    super.initState();
    // We'll fetch the route after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRoute();
    });
  }

  /// Fetches a road-based route between the user and car locations
  Future<void> _fetchRoute() async {
    final userData = Provider.of<AuthService>(context, listen: false).userData;

    // Parse car location
    LatLng? carLoc;
    if (widget.car.location.isNotEmpty) {
      // Car location uses lat/lng fields
      if (widget.car.location.containsKey('lat') &&
          widget.car.location.containsKey('lng')) {
        carLoc = LatLng(
          widget.car.location['lat']!,
          widget.car.location['lng']!,
        );
      }
      // Fallback to latitude/longitude format
      else if (widget.car.location.containsKey('latitude') &&
          widget.car.location.containsKey('longitude')) {
        carLoc = LatLng(
          widget.car.location['latitude']!,
          widget.car.location['longitude']!,
        );
      }
    }

    // Parse user location
    LatLng? userLoc;

    // Helper function to safely parse coordinate values
    double? parseCoordinate(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    if (userData != null) {
      // Check if location data exists
      final locData = userData['location'];
      if (locData != null && locData is Map) {
        // User location uses latitude/longitude fields
        if (locData.containsKey('latitude') &&
            locData.containsKey('longitude')) {
          final lat = parseCoordinate(locData['latitude']);
          final lng = parseCoordinate(locData['longitude']);
          if (lat != null && lng != null) {
            userLoc = LatLng(lat, lng);
          }
        }
        // Fallback to lat/lng format
        else if (locData.containsKey('lat') && locData.containsKey('lng')) {
          final lat = parseCoordinate(locData['lat']);
          final lng = parseCoordinate(locData['lng']);
          if (lat != null && lng != null) {
            userLoc = LatLng(lat, lng);
          }
        }
      }
    }

    // If we have both locations, fetch the route
    if (carLoc != null && userLoc != null) {
      setState(() {
        _loadingRoute = true;
        _routeError = '';
      });

      try {
        // Both userLoc and carLoc are non-null at this point
        final routePoints = await RoutingService.getRoute(userLoc, carLoc);

        setState(() {
          _routePoints = routePoints;
          _loadingRoute = false;
        });
      } catch (e) {
        setState(() {
          _routeError = 'Failed to load route: $e';
          _loadingRoute = false;
          // Fallback to straight line if both locations are available
          if (userLoc != null && carLoc != null) {
            _routePoints = [userLoc, carLoc];
          }
        });
      }
    } else {
      setState(() {
        _routeError = 'Cannot calculate route: Missing location data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Convert Firebase car location to LatLng
    LatLng? carLoc;
    if (widget.car.location.isNotEmpty) {
      // Car location uses lat/lng fields
      if (widget.car.location.containsKey('lat') &&
          widget.car.location.containsKey('lng')) {
        carLoc = LatLng(
          widget.car.location['lat']!,
          widget.car.location['lng']!,
        );
        print(
          'Car location found with lat/lng: ${carLoc.latitude}, ${carLoc.longitude}',
        );
      }
      // Fallback to latitude/longitude format
      else if (widget.car.location.containsKey('latitude') &&
          widget.car.location.containsKey('longitude')) {
        carLoc = LatLng(
          widget.car.location['latitude']!,
          widget.car.location['longitude']!,
        );
        print(
          'Car location found with latitude/longitude: ${carLoc.latitude}, ${carLoc.longitude}',
        );
      }
    }

    // Get user location from AuthService (Provider)
    final userData = Provider.of<AuthService>(context).userData;
    LatLng? userLoc;

    // Helper function to safely parse coordinate values
    double? parseCoordinate(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    if (userData != null) {
      // Check if location data exists
      final locData = userData['location'];
      if (locData != null && locData is Map) {
        // User location uses latitude/longitude fields
        if (locData.containsKey('latitude') &&
            locData.containsKey('longitude')) {
          final lat = parseCoordinate(locData['latitude']);
          final lng = parseCoordinate(locData['longitude']);
          if (lat != null && lng != null) {
            userLoc = LatLng(lat, lng);
          }
        }
        // Fallback to lat/lng format
        else if (locData.containsKey('lat') && locData.containsKey('lng')) {
          final lat = parseCoordinate(locData['lat']);
          final lng = parseCoordinate(locData['lng']);
          if (lat != null && lng != null) {
            userLoc = LatLng(lat, lng);
          }
        }
      }
    }
    final markers = <Marker>[];

    if (carLoc != null) {
      markers.add(
        Marker(
          width: 56,
          height: 56,
          point: carLoc,
          child: _MapMarker(
            carImage: widget.car.image,
            icon: 'assets/svg/car.svg',
            label: widget.car.type,
            color: Colors.blue,
          ),
        ),
      );
    }
    if (userLoc != null) {
      final profileImageUrl =
          userData != null ? userData['profileImageUrl'] as String? : null;
      markers.add(
        Marker(
          width: 56,
          height: 56,
          point: userLoc,
          child: _MapMarker(
            profileImageUrl: profileImageUrl,
            icon: 'assets/svg/user.svg',
            label: 'You',
            color: Colors.green,
          ),
        ),
      );
    }

    final center =
        carLoc ?? userLoc ?? LatLng(14.5995, 120.9842); // fallback Manila

    return Scaffold(
      appBar: AppBar(title: const Text('Car & Your Location')),
      body: Stack(
        children: [
          if (userLoc == null && carLoc == null)
            const Center(child: Text('No locations available'))
          else
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
                maxZoom: 18,
                minZoom: 3,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.car_rental_app',
                ),
                // Display either the road-based route or a fallback straight line
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        color: Colors.blue,
                        strokeWidth: 4,
                      ),
                    ],
                  )
                else if (userLoc != null && carLoc != null)
                  // Fallback to straight line if no route is available yet but we have both locations
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [userLoc, carLoc],
                        color: Colors.grey,
                        strokeWidth: 2,
                        // Create a dotted effect with pattern
                        strokeCap: StrokeCap.round,
                        gradientColors: [Colors.grey, Colors.transparent],
                      ),
                    ],
                  ),
                MarkerLayer(markers: markers),
              ],
            ),
          // Show loading indicator while fetching route
          if (_loadingRoute)
            const Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Calculating route...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Show error message if route calculation failed
          if (_routeError.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      _routeError,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final String? carImage; // For car marker
  final String? profileImageUrl; // For user marker
  final String icon;
  final String label;
  final Color color;
  const _MapMarker({
    this.carImage,
    this.profileImageUrl,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget markerVisual;
    if (profileImageUrl != null) {
      markerVisual = CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(profileImageUrl!),
        backgroundColor: Colors.grey[200],
      );
    } else if (carImage != null && carImage!.isNotEmpty) {
      // Always treat car images from Firebase as URLs
      markerVisual = Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: ClipOval(
          child: Image.network(
            carImage!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: const Icon(
                    Icons.car_rental,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
          ),
        ),
      );
    } else {
      markerVisual = SvgPicture.asset(
        icon,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }
    return SizedBox(
      height: 56,
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          markerVisual,
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 9, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
