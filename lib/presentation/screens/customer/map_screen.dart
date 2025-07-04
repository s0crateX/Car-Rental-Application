import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/authentication/auth_service.dart';
import '../../../shared/models/Final Model/Firebase_car_model.dart';
import '../../../shared/common_widgets/maps/interactive_map.dart';

class MapScreen extends StatelessWidget {
  final List<CarModel> cars;
  final LatLng userLocation;

  const MapScreen({super.key, required this.cars, required this.userLocation});

  @override
  Widget build(BuildContext context) {
    // Get the current user's profile image URL from AuthService via Provider
    final userData = Provider.of<AuthService>(context, listen: false).userData;
    final String? userProfileImageUrl =
        userData != null ? userData['profileImageUrl'] as String? : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Cars Near You')),
      body: InteractiveMap(
        initialLocation: userLocation,
        carMarkers: cars,
        enableTap: false,
        userProfileImageUrl: userProfileImageUrl ?? '',
      ),
    );
  }
}
