import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'interactive_map.dart';

class FullScreenMap extends StatefulWidget {
  final LatLng initialLocation;

  const FullScreenMap({super.key, required this.initialLocation});

  @override
  State<FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Location'),
      ),
      body: InteractiveMap(
        initialLocation: _selectedLocation,
        onLocationSelected: (location) {
          setState(() {
            _selectedLocation = location;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop(_selectedLocation);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
