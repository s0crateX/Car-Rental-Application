import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:car_rental_app/shared/common_widgets/maps/interactive_map.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

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
    await showDialog(
      context: context,
      builder: (context) {
        return _FullScreenMapDialog(
          initialLocation: _selectedLocation,
          onLocationSelected: (LatLng location) async {
            await _handleMapTap(location);
            Navigator.pop(context);
          },
          onCenterToCurrentLocation: () async {
            await _centerToCurrentLocation(fullScreen: true);
          },
        );
      },
    );
  }

  Future<void> _centerToCurrentLocation({bool fullScreen = false}) async {
    setState(() {
      _isCenteringLocation = true;
    });
    
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
    } finally {
      setState(() {
        _isCenteringLocation = false;
      });
    }
  }

  late LatLng _selectedLocation;
  final MapController _mapController = MapController();
  bool _showMap = false;
  Timer? _searchTimer;
  bool _isSearching = false;
  bool _isCenteringLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLocation ??
        const LatLng(6.1164, 125.1716); // Default to General Santos (Gensan)
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  void _toggleMap() {
    setState(() {
      _showMap = !_showMap;
    });
  }

  Future<void> _searchAddress(String address) async {
    if (address.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newLocation = LatLng(location.latitude, location.longitude);
        
        setState(() {
          _selectedLocation = newLocation;
          widget.onLocationSelected(newLocation);
        });

        // Move map to the new location if map is visible
        if (_showMap) {
          _mapController.move(newLocation, 16);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _onAddressChanged(String value) {
    // Cancel previous timer
    _searchTimer?.cancel();
    
    // Start new timer for debounced search
    _searchTimer = Timer(const Duration(milliseconds: 1500), () {
      if (value.trim().isNotEmpty) {
        _searchAddress(value);
      }
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
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'General Sans',
            letterSpacing: 0.15,
          ),
        ),
        const SizedBox(height: 20),

        // Address Input
        TextFormField(
          controller: widget.addressController,
          onChanged: _onAddressChanged,
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'General Sans',
            letterSpacing: 0.25,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. 123 Main Street, City',
            hintStyle: TextStyle(
              color: AppTheme.lightBlue.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w300,
              fontFamily: 'General Sans',
              letterSpacing: 0.25,
            ),
            filled: true,
            fillColor: AppTheme.darkNavy,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.mediumBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.lightBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.red,
                width: 2,
              ),
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                'assets/svg/location.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  AppTheme.lightBlue.withOpacity(0.8),
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: _isSearching
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightBlue.withOpacity(0.8),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: _toggleMap,
                      child: SvgPicture.asset(
                        'assets/svg/map-2.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          AppTheme.lightBlue.withOpacity(0.8),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the car location';
            }
            return null;
          },
        ),

        // Map Toggle Button
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _toggleMap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              _showMap ? 'Hide Map' : 'Show on Map',
              style: TextStyle(
                color: AppTheme.lightBlue,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'General Sans',
                letterSpacing: 0.25,
              ),
            ),
          ),
        ),

        // Map View
        if (_showMap) ...[
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.mediumBlue.withOpacity(0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkNavy.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: InteractiveMap(
                    initialLocation: _selectedLocation,
                    enableTap: true,
                    onLocationSelected: _handleMapTap,
                    mapController: _mapController,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkNavy.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.mediumBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _showFullScreenMap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fullscreen,
                              size: 16,
                              color: AppTheme.lightBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Full Screen',
                              style: TextStyle(
                                color: AppTheme.lightBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'General Sans',
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
                  elevation: 4,
                  onPressed: _isCenteringLocation ? null : _centerToCurrentLocation,
                  child: _isCenteringLocation
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.darkNavy,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.my_location, 
                          color: AppTheme.darkNavy,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.navy.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.paleBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppTheme.paleBlue.withOpacity(0.8),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap on the map to set the exact location',
                    style: TextStyle(
                      color: AppTheme.paleBlue.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'General Sans',
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FullScreenMapDialog extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationSelected;
  final VoidCallback onCenterToCurrentLocation;

  const _FullScreenMapDialog({
    required this.initialLocation,
    required this.onLocationSelected,
    required this.onCenterToCurrentLocation,
  });

  @override
  State<_FullScreenMapDialog> createState() => _FullScreenMapDialogState();
}

class _FullScreenMapDialogState extends State<_FullScreenMapDialog> {
  late LatLng _currentLocation;
  late MapController _fullScreenMapController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchTimer;
  bool _isSearching = false;
  bool _isCenteringLocation = false;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    _fullScreenMapController = MapController();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress(String address) async {
    if (address.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newLocation = LatLng(location.latitude, location.longitude);
        
        setState(() {
          _currentLocation = newLocation;
        });

        // Move map to the new location
        _fullScreenMapController.move(newLocation, 15.0);
      }
    } catch (e) {
      // Handle search error silently
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 800), () {
      _searchAddress(value);
    });
  }

  Future<void> _handleCenterToCurrentLocation() async {
    setState(() {
      _isCenteringLocation = true;
    });

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

      setState(() {
        _currentLocation = currentLatLng;
      });

      // Move map to current location
      _fullScreenMapController.move(currentLatLng, 16.0);

      // Call the parent's location selected callback
      widget.onLocationSelected(currentLatLng);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get current location: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCenteringLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.lightBlue,
        elevation: 0,
        title: Text(
          'Select Location on Map',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: 'General Sans',
            letterSpacing: 0.15,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: Stack(
        children: [
          // Full-screen Map
          InteractiveMap(
            initialLocation: _currentLocation,
            enableTap: true,
            onLocationSelected: widget.onLocationSelected,
            mapController: _fullScreenMapController,
          ),
          // Floating Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.mediumBlue.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.darkNavy.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(
                  color: AppTheme.paleBlue,
                  fontSize: 16,
                  fontFamily: 'General Sans',
                ),
                decoration: InputDecoration(
                  hintText: 'Search for a location...',
                  filled: true,
                  fillColor: AppTheme.darkNavy,
                  hintStyle: TextStyle(
                    color: AppTheme.mediumBlue,
                    fontSize: 16,
                    fontFamily: 'General Sans',
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.lightBlue.withOpacity(0.8),
                    size: 20,
                  ),
                  suffixIcon: _isSearching
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.lightBlue.withOpacity(0.8),
                              ),
                            ),
                          ),
                        )
                      : _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppTheme.lightBlue.withOpacity(0.8),
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _searchTimer?.cancel();
                              },
                            )
                          : null,
                ),
              ),
            ),
          ),
          // Floating Center Location Button
          Positioned(
            bottom: 32,
            right: 24,
            child: FloatingActionButton(
              heroTag: 'fullscreen_center_location_btn',
              backgroundColor: AppTheme.lightBlue,
              elevation: 4,
              onPressed: _isCenteringLocation ? null : _handleCenterToCurrentLocation,
              child: _isCenteringLocation
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.darkNavy,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.my_location, 
                      color: AppTheme.darkNavy,
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
