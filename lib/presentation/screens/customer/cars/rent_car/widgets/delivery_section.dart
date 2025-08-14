import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/shared/common_widgets/maps/full_screen_map.dart';
import 'package:car_rental_app/shared/common_widgets/maps/interactive_map.dart';
import 'package:car_rental_app/models/Firebase_car_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

enum DeliveryOption { pickup, delivery }

class DeliverySection extends StatefulWidget {
  final Function(
    bool isDelivery,
    LatLng? latLng,
    String? address,
    double deliveryCharge,
  )
  onDeliveryChanged;
  final CarModel car;

  const DeliverySection({
    super.key,
    required this.onDeliveryChanged,
    required this.car,
  });

  @override
  State<DeliverySection> createState() => _DeliverySectionState();
}

class _DeliverySectionState extends State<DeliverySection>
    with SingleTickerProviderStateMixin {
  DeliveryOption _selectedOption = DeliveryOption.pickup;
  String? _deliveryAddress;
  LatLng? _deliveryLatLng;
  final LocationService _locationService = LocationService();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  
  // New state variables from location_section_widget
  final MapController _mapController = MapController();
  bool _isCenteringLocation = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onOptionChanged(DeliveryOption option) {
    setState(() {
      _selectedOption = option;
      if (option == DeliveryOption.pickup) {
        _animationController.reverse();
        _deliveryLatLng = null;
        _deliveryAddress = null;
        widget.onDeliveryChanged(false, null, null, 0.0);
      } else {
        _animationController.forward();
        if (_deliveryLatLng != null && _deliveryAddress != null) {
          widget.onDeliveryChanged(
            true,
            _deliveryLatLng,
            _deliveryAddress,
            widget.car.deliveryCharge,
          );
        }
      }
    });
  }

  Future<void> _fetchUserLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final locationData = authService.userData?['location'];
      if (locationData != null &&
          locationData['latitude'] != null &&
          locationData['longitude'] != null) {
        final lat = locationData['latitude'];
        final lng = locationData['longitude'];

        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final fullAddress = _formatAddress(placemark);
          setState(() {
            _deliveryLatLng = LatLng(lat, lng);
            _deliveryAddress = fullAddress;
            widget.onDeliveryChanged(
              true,
              _deliveryLatLng,
              _deliveryAddress,
              widget.car.deliveryCharge,
            );
          });
        } else {
          setState(() {
            _deliveryLatLng = LatLng(lat, lng);
            _deliveryAddress =
                'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
            widget.onDeliveryChanged(
              true,
              _deliveryLatLng,
              _deliveryAddress,
              widget.car.deliveryCharge,
            );
          });
        }
      } else {
        if (mounted) {
          _showSnackBar('No saved location found in profile.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Error fetching saved location: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final position = await _locationService.getCurrentLocation();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final fullAddress = _formatAddress(placemark);
        setState(() {
          _deliveryLatLng = LatLng(position.latitude, position.longitude);
          _deliveryAddress = fullAddress;
          widget.onDeliveryChanged(
            true,
            _deliveryLatLng,
            _deliveryAddress,
            widget.car.deliveryCharge,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error getting location: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatAddress(Placemark placemark) {
    final components = [
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.postalCode,
    ].where((component) => component != null && component.isNotEmpty);

    return components.join(', ');
  }

  Future<void> _openFullScreenMap() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder:
            (context) => FullScreenMap(
              initialLocation: _deliveryLatLng ?? LatLng(6.1167, 125.1667),
            ),
      ),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          result.latitude,
          result.longitude,
        );
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final fullAddress = _formatAddress(placemark);
          setState(() {
            _deliveryLatLng = result;
            _deliveryAddress = fullAddress;
            widget.onDeliveryChanged(
              true,
              _deliveryLatLng,
              _deliveryAddress,
              widget.car.deliveryCharge,
            );
          });
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar(
            'Error getting address: ${e.toString()}',
            isError: true,
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // New methods from location_section_widget

  Future<void> _handleMapTap(LatLng location) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      
      String fullAddress;
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        fullAddress = _formatAddress(placemark);
      } else {
        fullAddress = 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
      }
      
      setState(() {
        _deliveryLatLng = location;
        _deliveryAddress = fullAddress;
        widget.onDeliveryChanged(
          true,
          _deliveryLatLng,
          _deliveryAddress,
          widget.car.deliveryCharge,
        );
      });
    } catch (e) {
      _showSnackBar('Error getting address: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
          _showSnackBar('Location permissions are denied.', isError: true);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied.', isError: true);
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
        await _handleMapTap(currentLatLng);
        _mapController.move(currentLatLng, 16);
      }
    } catch (e) {
      _showSnackBar('Failed to get current location: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isCenteringLocation = false;
      });
    }
  }

  Future<void> _showFullScreenMapDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return _FullScreenMapDialog(
          initialLocation: _deliveryLatLng ?? LatLng(6.1167, 125.1667),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Delivery Options',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Option Selector
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onOptionChanged(DeliveryOption.pickup),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              _selectedOption == DeliveryOption.pickup
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store,
                              size: 16,
                              color:
                                  _selectedOption == DeliveryOption.pickup
                                      ? Colors.white
                                      : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Pickup',
                              style: TextStyle(
                                color:
                                    _selectedOption == DeliveryOption.pickup
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onOptionChanged(DeliveryOption.delivery),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              _selectedOption == DeliveryOption.delivery
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_shipping,
                              size: 16,
                              color:
                                  _selectedOption == DeliveryOption.delivery
                                      ? Colors.white
                                      : Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Delivery',
                              style: TextStyle(
                                color:
                                    _selectedOption == DeliveryOption.delivery
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delivery Charge Info
            if (_selectedOption == DeliveryOption.delivery) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.darkNavy,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery Charge',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.lightBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₱${widget.car.deliveryCharge.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.lightBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Expandable Content for Delivery
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),


                  // Address Display
                  if (_deliveryAddress != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.darkNavy,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppTheme.lightBlue,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _deliveryAddress!,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_deliveryAddress != null) const SizedBox(height: 10),

                  // Enhanced Map View
                  const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppTheme.lightBlue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : InteractiveMap(
                                    initialLocation: _deliveryLatLng ??
                                        LatLng(6.1167, 125.1667),
                                    enableTap: true,
                                    onLocationSelected: _handleMapTap,
                                    mapController: _mapController,
                                  ),
                          ),
                        ),
                        // Full Screen Button
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.darkNavy.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(6),
                                onTap: _showFullScreenMapDialog,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.fullscreen,
                                        size: 14,
                                        color: AppTheme.lightBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Full Screen',
                                        style: TextStyle(
                                          color: AppTheme.lightBlue,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Center Location Button
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: FloatingActionButton(
                            heroTag: 'delivery_center_location_btn',
                            mini: true,
                            backgroundColor: AppTheme.lightBlue,
                            elevation: 2,
                            onPressed: _isCenteringLocation
                                ? null
                                : () => _centerToCurrentLocation(),
                            child: _isCenteringLocation
                                ? SizedBox(
                                    width: 14,
                                    height: 14,
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
                                    size: 16,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.darkNavy.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: AppTheme.lightBlue.withOpacity(0.8),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tap on the map to set delivery location',
                              style: TextStyle(
                                color: AppTheme.lightBlue.withOpacity(0.8),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Compact Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactButton(
                          icon: Icons.my_location,
                          label: 'Current',
                          onPressed: _isLoading || _isCenteringLocation
                              ? null
                              : () => _centerToCurrentLocation(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCompactButton(
                          icon: Icons.home,
                          label: 'Saved',
                          onPressed: _isLoading ? null : _fetchUserLocation,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCompactButton(
                          icon: Icons.fullscreen,
                          label: 'Map',
                          onPressed: _showFullScreenMapDialog,
                        ),
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

  Widget _buildCompactButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide.none,
        backgroundColor: AppTheme.darkNavy,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

// Full Screen Map Dialog from location_section_widget
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
        backgroundColor: AppTheme.navy,
        elevation: 0,
        title: const Text(
          'Select Delivery Location',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
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
                  color: AppTheme.lightBlue.withOpacity(0.3),
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
                style: const TextStyle(
                  color: AppTheme.darkNavy,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for delivery location...',
                  filled: true,
                  fillColor: AppTheme.darkNavy,
                  hintStyle: TextStyle(
                    color: AppTheme.paleBlue,
                    fontSize: 16,
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
              heroTag: 'fullscreen_delivery_center_location_btn',
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
