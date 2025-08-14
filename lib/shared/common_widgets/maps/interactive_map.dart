import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../config/theme.dart';

class InteractiveMap extends StatefulWidget {
  final LatLng initialLocation;
  final double initialZoom;
  final bool enableTap;
  final Function(LatLng)? onLocationSelected;
  final MapController? mapController;
  final List<dynamic>? carMarkers; // Accepts List<CarModel> or List<Map<String, dynamic>>
  final String? userProfileImageUrl;
  final bool showLocationPin;

  const InteractiveMap({
    super.key,
    required this.initialLocation,
    this.initialZoom = 15.0,
    this.enableTap = true,
    this.onLocationSelected,
    this.mapController,
    this.carMarkers,
    this.userProfileImageUrl,
    this.showLocationPin = true,
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
  void didUpdateWidget(InteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLocation != widget.initialLocation) {
      setState(() {
        _selectedLocation = widget.initialLocation;
      });
    }
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
        // Car markers
        if (widget.carMarkers != null)
          MarkerLayer(
            markers: widget.carMarkers!
                .where((car) =>
                    car.location != null &&
                    car.location.containsKey('latitude') &&
                    car.location.containsKey('longitude'))
                .map<Marker>((car) => Marker(
                      point: LatLng(
                        car.location['latitude'] ?? 0.0,
                        car.location['longitude'] ?? 0.0,
                      ),
                      width: 54,
                      height: 54,
                      child: Tooltip(
                        message: car.brand + ' ' + car.model,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blueAccent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: car.image.startsWith('http') || car.image.startsWith('https')
                              ? Image.network(
                                  car.image,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.directions_car, size: 32, color: Colors.redAccent),
                                )
                              : Image.asset(
                                  car.image,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.directions_car, size: 32, color: Colors.redAccent),
                                ),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        // User selected location marker
        if (widget.showLocationPin)
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedLocation,
                width: 30,
                height: 30,
                child: widget.userProfileImageUrl != null &&
                        widget.userProfileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                        radius: 22,
                        backgroundColor: AppTheme.mediumBlue,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              NetworkImage(widget.userProfileImageUrl!),
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/svg/location.svg',
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          AppTheme.darkNavy,
                          BlendMode.srcIn,
                        ),
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
