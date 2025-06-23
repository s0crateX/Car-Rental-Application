import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:car_rental_app/shared/common_widgets/maps/interactive_map.dart';
import 'package:car_rental_app/config/theme.dart';

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

  void _handleMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      widget.onLocationSelected(location);
      // In a real app, you would want to reverse geocode the coordinates to an address
      // and update the addressController.text with the result
    });
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
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.3)),
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
