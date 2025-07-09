import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/core/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/shared/common_widgets/maps/full_screen_map.dart';
import 'package:car_rental_app/shared/common_widgets/maps/interactive_map.dart';
import 'package:car_rental_app/shared/models/Final Model/Firebase_car_model.dart';

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

                  // Compact Map
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child:
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : InteractiveMap(
                                initialLocation:
                                    _deliveryLatLng ?? LatLng(6.1167, 125.1667),
                                onLocationSelected: (location) async {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  try {
                                    List<Placemark> placemarks =
                                        await placemarkFromCoordinates(
                                          location.latitude,
                                          location.longitude,
                                        );
                                    if (placemarks.isNotEmpty) {
                                      final placemark = placemarks.first;
                                      final fullAddress = _formatAddress(
                                        placemark,
                                      );
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
                                },
                              ),
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
                          onPressed: _isLoading ? null : _getCurrentLocation,
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
                          onPressed: _openFullScreenMap,
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
