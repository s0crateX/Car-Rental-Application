import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import '../../../../../../shared/models/car_model.dart';

class CarLocationMapScreen extends StatefulWidget {
  final CarModel car;
  const CarLocationMapScreen({super.key, required this.car});

  @override
  State<CarLocationMapScreen> createState() => _CarLocationMapScreenState();
}

class _CarLocationMapScreenState extends State<CarLocationMapScreen> {
  // Removed _userLocation and _loadingUserLocation as they are no longer used.

  @override
  void initState() {
    super.initState();
    // No async fetching needed; will read from Provider in build
  }

  @override
  Widget build(BuildContext context) {
    final carLoc = widget.car.location;
    // Get user location from AuthService (Provider)
    final userData = Provider.of<AuthService>(context).userData;
    LatLng? userLoc;
    final locData = userData != null ? userData['location'] : null;
    if (locData != null && locData is Map) {
      final lat = locData['latitude'];
      final lng = locData['longitude'];
      if (lat != null && lng != null) {
        userLoc = LatLng(lat.toDouble(), lng.toDouble());
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
            label: widget.car.name,
            color: Colors.blue,
          ),
        ),
      );
    }
    if (userLoc != null) {
      final profileImageUrl = userData != null ? userData['profileImageUrl'] as String? : null;
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
      body:
          userLoc == null && carLoc == null
              ? const Center(child: Text('No locations available'))
              : FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 13,
                  maxZoom: 18,
                  minZoom: 3,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.car_rental_app',
                  ),
                  MarkerLayer(markers: markers),
                  if (userLoc != null && carLoc != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [userLoc, carLoc],
                          color: Colors.blueAccent,
                          strokeWidth: 4,
                        ),
                      ],
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
    } else if (carImage != null) {
      markerVisual = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          carImage!,
          width: 32,
          height: 24,
          fit: BoxFit.cover,
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
