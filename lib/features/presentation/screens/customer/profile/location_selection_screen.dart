import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../config/theme.dart';
import '../../../../../shared/common_widgets/maps/interactive_map.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/success_snackbar.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/error_snackbar.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final MapController _mapController = MapController();
  LatLng _selectedLocation = LatLng(14.5995, 120.9842); // Default to Manila
  bool _isLoading = false;
  bool _locationPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final double? lat = prefs.getDouble('user_location_lat');
      final double? lng = prefs.getDouble('user_location_lng');

      if (lat != null && lng != null) {
        setState(() {
          _selectedLocation = LatLng(lat, lng);
        });
      } else {
        // Try to get current location if no saved location
        _getCurrentLocation();
      }
    } catch (e) {
      debugPrint('Error loading saved location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save locally for offline use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('user_location_lat', _selectedLocation.latitude);
      await prefs.setDouble('user_location_lng', _selectedLocation.longitude);

      // Save to Firebase (user profile)
      final locationData = {
        'location': {
          'latitude': _selectedLocation.latitude,
          'longitude': _selectedLocation.longitude,
        }
      };
      await Provider.of<AuthService>(context, listen: false).updateUserProfileData(locationData);

      if (mounted) {
        SuccessSnackbar.show(
          context: context,
          message: 'Location saved successfully',
        );
        Navigator.pop(context, _selectedLocation);
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackbar.show(
          context: context,
          message: 'Error saving location: $e',
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationPermissionDenied = false;
    });

    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location services are disabled. Please enable GPS to get your current location.'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
      return;
    }

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationPermissionDenied = true;
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationPermissionDenied = true;
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      // Animate to the current location
      _mapController.move(_selectedLocation, 15.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      appBar: AppBar(
        backgroundColor: AppTheme.darkNavy,
        elevation: 0,
        title: const Text(
          'Set Your Location',
          style: TextStyle(fontSize: 20, color: AppTheme.white),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/svg/arrow-left.svg',
            colorFilter: const ColorFilter.mode(
              AppTheme.white,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          _buildMap(),
          _buildLocationInfo(),
          if (_isLoading) _buildLoadingIndicator(),
          if (_locationPermissionDenied) _buildPermissionDeniedMessage(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'getCurrentLocation',
            onPressed: _getCurrentLocation,
            backgroundColor: AppTheme.mediumBlue,
            child: const Icon(Icons.my_location, color: AppTheme.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'saveLocation',
            onPressed: _saveLocation,
            backgroundColor: AppTheme.lightBlue,
            child: const Icon(Icons.check, color: AppTheme.navy),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return InteractiveMap(
      mapController: _mapController,
      initialLocation: _selectedLocation,
      initialZoom: 15.0,
      onLocationSelected: (LatLng location) {
        setState(() {
          _selectedLocation = location;
        });
      },
    );
  }

  Widget _buildLocationInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.navy.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selected Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Latitude: ${_selectedLocation.latitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 14, color: AppTheme.paleBlue),
            ),
            const SizedBox(height: 4),
            Text(
              'Longitude: ${_selectedLocation.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 14, color: AppTheme.paleBlue),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap on the map to select a location or use the location button to get your current position.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.paleBlue.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightBlue,
                  foregroundColor: AppTheme.navy,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Save Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: AppTheme.darkNavy.withOpacity(0.7),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.lightBlue),
      ),
    );
  }

  Widget _buildPermissionDeniedMessage() {
    return Container(
      color: AppTheme.darkNavy.withOpacity(0.9),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_disabled,
              color: AppTheme.paleBlue,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Location Permission Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please enable location permissions in your device settings to use this feature.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.paleBlue.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await Geolocator.openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.mediumBlue,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
