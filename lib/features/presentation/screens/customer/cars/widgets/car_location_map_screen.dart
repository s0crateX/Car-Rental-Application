import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../shared/models/car_model.dart';
import '../../../../../../shared/utils/location_utils.dart';

class CarLocationMapScreen extends StatefulWidget {
  final CarModel car;
  const CarLocationMapScreen({Key? key, required this.car}) : super(key: key);

  @override
  State<CarLocationMapScreen> createState() => _CarLocationMapScreenState();
}

class _CarLocationMapScreenState extends State<CarLocationMapScreen> {
  LatLng? _userLocation;
  bool _loadingUserLocation = true;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    final loc = await LocationUtils().getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLocation = loc;
        _loadingUserLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final carLoc = widget.car.location;
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
    if (_userLocation != null) {
      markers.add(
        Marker(
          width: 56,
          height: 56,
          point: _userLocation!,
          child: _MapMarker(
            icon: 'assets/svg/user.svg',
            label: 'You',
            color: Colors.green,
          ),
        ),
      );
    }

    final center = carLoc ?? _userLocation ?? LatLng(14.5995, 120.9842); // fallback Manila

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car & Your Location'),
      ),
      body: _loadingUserLocation && _userLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
                maxZoom: 18,
                minZoom: 3,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.car_rental_app',
                ),
                MarkerLayer(markers: markers),
                if (_userLocation != null && carLoc != null)
                  PolylineLayer(polylines: [
                    Polyline(
                      points: [_userLocation!, carLoc],
                      color: Colors.blueAccent,
                      strokeWidth: 4,
                    ),
                  ]),
              ],
            ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final String? carImage; // If null, fallback to icon
  final String icon;
  final String label;
  final Color color;
  const _MapMarker({this.carImage, required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (carImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                carImage!,
                width: 32,
                height: 24,
                fit: BoxFit.cover,
              ),
            )
          else
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
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
