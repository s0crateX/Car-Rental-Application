import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/models/car_model.dart';
import '../../../../shared/common_widgets/maps/interactive_map.dart';

class MapScreen extends StatelessWidget {
  final List<CarModel> cars;
  final LatLng userLocation;

  const MapScreen({
    super.key,
    required this.cars,
    required this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cars Near You'),
      ),
      body: InteractiveMap(
        initialLocation: userLocation,
        carMarkers: cars,
        enableTap: false,
      ),
    );
  }
}
