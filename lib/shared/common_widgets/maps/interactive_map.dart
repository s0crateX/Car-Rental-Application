import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../config/theme.dart';

class InteractiveMap extends StatefulWidget {
  final LatLng initialLocation;
  final double initialZoom;
  final bool enableTap;
  final Function(LatLng)? onLocationSelected;
  final MapController? mapController;

  const InteractiveMap({
    super.key,
    required this.initialLocation,
    this.initialZoom = 15.0,
    this.enableTap = true,
    this.onLocationSelected,
    this.mapController,
  });

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  late MapController _mapController;
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
    _selectedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    if (widget.mapController == null) {
      _mapController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.initialLocation,
        initialZoom: widget.initialZoom,
        onTap: widget.enableTap
            ? (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
                if (widget.onLocationSelected != null) {
                  widget.onLocationSelected!(point);
                }
              }
            : null,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.car_rental_app',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _selectedLocation,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_on,
                color: AppTheme.mediumBlue,
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Public method to move the map to a specific location
  void moveToLocation(LatLng location, [double? zoom]) {
    _mapController.move(location, zoom ?? widget.initialZoom);
    setState(() {
      _selectedLocation = location;
    });
    if (widget.onLocationSelected != null) {
      widget.onLocationSelected!(location);
    }
  }
}
