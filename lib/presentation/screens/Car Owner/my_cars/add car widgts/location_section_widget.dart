import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:car_rental_app/shared/common_widgets/maps/interactive_map.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationSectionWidget extends StatefulWidget {
  final TextEditingController addressController;
  final Function(LatLng) onLocationSelected;
  final LatLng? initialLocation;

  const LocationSectionWidget({
    super.key,
    required this.addressController,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<LocationSectionWidget> createState() => _LocationSectionWidgetState();
}

class _LocationSectionWidgetState extends State<LocationSectionWidget> {
  // ...existing fields...

  Future<void> _showFullScreenMap() async {
    LatLng selected = _selectedLocation;
    await showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: AppTheme.navy,
            title: const Text('Select Location on Map'),
            actions: [],
          ),
          body: Stack(
            children: [
              InteractiveMap(
                initialLocation: selected,
                enableTap: true,
                onLocationSelected: (LatLng loc) async {
                  await _handleMapTap(loc);
                  Navigator.pop(context); // close full screen map
                },
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  heroTag: 'fullscreen_center_location_btn',
                  mini: true,
                  backgroundColor: AppTheme.lightBlue,
                  child: const Icon(Icons.my_location, color: Colors.white),
                  onPressed: () async {
                    await _centerToCurrentLocation(fullScreen: true);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _centerToCurrentLocation({bool fullScreen = false}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng currentLatLng = LatLng(
        position.latitude,
        position.longitude,
      );
      if (fullScreen) {
        await _handleMapTap(currentLatLng);
      } else {
        setState(() {
          _selectedLocation = currentLatLng;
        });
        await _handleMapTap(currentLatLng);
        _mapController.move(currentLatLng, 16);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get current location: $e')),
      );
    }
  }

  late LatLng _selectedLocation;
  final MapController _mapController = MapController();
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLocation ??
        const LatLng(6.1164, 125.1716); // Default to General Santos (Gensan)
  }

  void _toggleMap() {
    setState(() {
      _showMap = !_showMap;
    });
  }

  Future<void> _handleMapTap(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      widget.onLocationSelected(location);
    });
    // Show loading indicator while fetching address
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      // Use the geocoding package to get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = [
          if (place.name != null && place.name!.isNotEmpty) place.name,
          if (place.street != null && place.street!.isNotEmpty) place.street,
          if (place.subLocality != null && place.subLocality!.isNotEmpty)
            place.subLocality,
          if (place.locality != null && place.locality!.isNotEmpty)
            place.locality,
          if (place.administrativeArea != null &&
              place.administrativeArea!.isNotEmpty)
            place.administrativeArea,
          if (place.country != null && place.country!.isNotEmpty) place.country,
        ].whereType<String>().join(', ');
        setState(() {
          widget.addressController.text = address;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get address: $e')));
    } finally {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(); // Remove loading indicator
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Car Location',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Address Input
        TextFormField(
          controller: widget.addressController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter car location address',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: AppTheme.navy.withOpacity(0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                'assets/images/cars/car-location.png',
                width: 28,
                height: 28,
                color: AppTheme.lightBlue,
              ),
            ),
            suffixIcon: IconButton(
              icon: SvgPicture.asset(
                'assets/svg/map-2.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppTheme.lightBlue,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: _toggleMap,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the car location';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        // Lat/Lng Display
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.navy.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_searching,
                color: AppTheme.lightBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lat:  a0${_selectedLocation.latitude.toStringAsFixed(6)}  |  Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),

        // Map Toggle Button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _toggleMap,
            child: Text(
              _showMap ? 'Hide Map' : 'Show on Map',
              style: TextStyle(color: AppTheme.lightBlue),
            ),
          ),
        ),

        // Map View
        if (_showMap) ...[
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.mediumBlue.withOpacity(0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveMap(
                    initialLocation: _selectedLocation,
                    enableTap: true,
                    onLocationSelected: _handleMapTap,
                    mapController: _mapController,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mediumBlue.withOpacity(0.85),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                  icon: const Icon(
                    Icons.fullscreen,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Full Screen',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  onPressed: _showFullScreenMap,
                ),
              ),
              // Center location button
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'center_location_btn',
                  mini: true,
                  backgroundColor: AppTheme.lightBlue,
                  onPressed: _centerToCurrentLocation,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.paleBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap on the map to set the exact location',
                  style: TextStyle(color: AppTheme.paleBlue, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
