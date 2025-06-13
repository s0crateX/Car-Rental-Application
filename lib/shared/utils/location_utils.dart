import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationUtils {
  /// Singleton instance
  static final LocationUtils _instance = LocationUtils._internal();
  factory LocationUtils() => _instance;
  LocationUtils._internal();

  /// Cache for the last known user location
  LatLng? _lastKnownUserLocation;
  DateTime? _lastLocationTime;

  /// Maximum age of cached location in minutes
  final int _maxLocationAgeMinutes = 5;

  /// Get the user's current location
  Future<LatLng?> getCurrentLocation() async {
    // Check if we have a recent cached location
    if (_lastKnownUserLocation != null && _lastLocationTime != null) {
      final locationAge = DateTime.now().difference(_lastLocationTime!).inMinutes;
      if (locationAge < _maxLocationAgeMinutes) {
        return _lastKnownUserLocation;
      }
    }

    try {
      // Check location permissions
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        return null;
      }

      // Get the current position
      final position = await Geolocator.getCurrentPosition();
      _lastKnownUserLocation = LatLng(position.latitude, position.longitude);
      _lastLocationTime = DateTime.now();
      
      return _lastKnownUserLocation;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Calculate distance between user and car location
  Future<double?> getDistanceToCarInKm(LatLng? carLocation) async {
    if (carLocation == null) {
      return null;
    }

    final userLocation = await getCurrentLocation();
    if (userLocation == null) {
      return null;
    }

    // Calculate distance using the Distance class from latlong2
    final distance = const Distance().as(LengthUnit.Kilometer, 
      userLocation, carLocation);
    
    return distance;
  }

  /// Format distance for display
  String formatDistance(double? distanceInKm) {
    if (distanceInKm == null) {
      return 'Unknown distance';
    }
    
    if (distanceInKm < 1) {
      // Convert to meters for distances less than 1 km
      final meters = (distanceInKm * 1000).round();
      return '$meters m away';
    } else if (distanceInKm < 10) {
      // Show one decimal place for distances less than 10 km
      return '${distanceInKm.toStringAsFixed(1)} km away';
    } else {
      // Round to nearest km for larger distances
      return '${distanceInKm.round()} km away';
    }
  }
}
