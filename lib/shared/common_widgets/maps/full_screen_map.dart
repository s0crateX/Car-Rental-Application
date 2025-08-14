import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';
import 'interactive_map.dart';
import '../../../config/theme.dart';

class FullScreenMap extends StatefulWidget {
  final LatLng initialLocation;

  const FullScreenMap({super.key, required this.initialLocation});

  @override
  State<FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  late LatLng _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Location> _searchResults = [];
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      setState(() {
        _searchResults = locations;
        _showResults = locations.isNotEmpty;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _showResults = false;
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location not found. Please try a different search term.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<String> _getAddressFromLocation(Location location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final components = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
          placemark.postalCode,
        ].where((component) => component != null && component.isNotEmpty);
        return components.join(', ');
      }
    } catch (e) {
      // If reverse geocoding fails, return coordinates
    }
    return 'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}';
  }

  void _selectSearchResult(Location location) {
    // Add random offset to show general area instead of exact location
    final random = Random();
    // Offset range: approximately 100-500 meters (0.001 to 0.005 degrees)
    final latOffset = (random.nextDouble() - 0.5) * 0.008; // -0.004 to +0.004
    final lngOffset = (random.nextDouble() - 0.5) * 0.008; // -0.004 to +0.004
    
    final newLocation = LatLng(
      location.latitude + latOffset,
      location.longitude + lngOffset,
    );
    setState(() {
      _selectedLocation = newLocation;
      _showResults = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Location'),
      ),
      body: Stack(
        children: [
          InteractiveMap(
            initialLocation: _selectedLocation,
            onLocationSelected: (location) {
              setState(() {
                _selectedLocation = location;
                _showResults = false;
              });
            },
          ),
          // Floating Search Bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a location...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      prefixIcon: Icon(Icons.search, color: AppTheme.lightBlue),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _showResults = false;
                                      _searchResults = [];
                                    });
                                  },
                                )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.trim().isNotEmpty) {
                        _searchLocation(value);
                      } else {
                        setState(() {
                          _showResults = false;
                          _searchResults = [];
                        });
                      }
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _searchLocation(value);
                      }
                    },
                  ),
                ),
                // Search Results
                if (_showResults && _searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _searchResults.length > 5 ? 5 : _searchResults.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                      itemBuilder: (context, index) {
                        final location = _searchResults[index];
                        return FutureBuilder<String>(
                          future: _getAddressFromLocation(location),
                          builder: (context, snapshot) {
                            return ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: AppTheme.lightBlue,
                                size: 20,
                              ),
                              title: Text(
                                snapshot.data ?? 'Loading address...',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              onTap: () => _selectSearchResult(location),
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
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
