import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../../core/authentication/auth_service.dart';
import '../../../../shared/common_widgets/car_card_compact.dart';
// Ensure CarCardCompact uses Firebase_car_model.dart, not mock model

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../models/Firebase_car_model.dart';
import 'car_details_screen.dart';
import 'car_filter_bottom_sheet.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showScrollToTop = false;
  String _searchQuery = '';
  CarFilter _currentFilter = CarFilter();

    @override
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 200 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }





  Position? get _userLocation {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = authService.userData;
    final locData = userData != null ? userData['location'] : null;
    if (locData != null && locData is Map) {
      final lat = locData['latitude'];
      final lng = locData['longitude'];
      if (lat != null && lng != null) {
        return Position(
          latitude: lat.toDouble(),
          longitude: lng.toDouble(),
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      }
    }
    return null;
  }

  double _calculateDistance(CarModel car) {
    final userLoc = _userLocation;
    if (userLoc == null ||
        car.location.isEmpty ||
        car.location['latitude'] == null ||
        car.location['longitude'] == null) {
      return double.infinity;
    }
    return Geolocator.distanceBetween(
      userLoc.latitude,
      userLoc.longitude,
      car.location['latitude']!,
      car.location['longitude']!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(theme),
                      const SizedBox(height: 16),
                      _buildSearchBar(theme),

                      const SizedBox(height: 24),
                      _buildAllCarsSection(theme),
                    ],
                  ),
                ),
              ),
            if (_showScrollToTop)
              Positioned(
                right: 16,
                bottom: 32,
                child: FloatingActionButton(
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  },
                  backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
                  child: SvgPicture.asset(
                    'assets/svg/arrow-up.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Find Your Ride',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/svg/search.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.onSurface.withOpacity(0.7),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
              decoration: InputDecoration(
                hintText: 'Search for cars',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _showFilterBottomSheet,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                'assets/svg/filter.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() async {
    final result = await showModalBottomSheet<CarFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CarFilterBottomSheet(
        initialFilter: _currentFilter,
      ),
    );

    if (result != null) {
      setState(() {
        _currentFilter = result;
      });
    }
  }

  Widget _buildAllCarsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Cars',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Cars').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading cars'));
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(child: Text('No cars available'));
            }
            var cars =
                docs.map((doc) => CarModel.fromFirestore(doc)).toList();

            // Filter for verified cars only
            cars = cars
                .where((car) => car.verificationStatus == VerificationStatus.verified)
                .toList();

            // Apply search query
            if (_searchQuery.isNotEmpty) {
              cars = cars
                  .where((car) =>
                      ("${car.brand.toLowerCase()} ${car.model.toLowerCase()}")
                          .contains(_searchQuery.toLowerCase()) ||
                      car.type
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                  .toList();
            }

            // Apply filters from bottom sheet
            // Car Type
            if (_currentFilter.carType != null &&
                _currentFilter.carType != 'All') {
              cars = cars
                  .where((car) => car.type == _currentFilter.carType)
                  .toList();
            }

            // Price Range
            if (_currentFilter.priceRange != null) {
              cars = cars
                  .where((car) =>
                      car.hourlyRate >= _currentFilter.priceRange!.start &&
                      car.hourlyRate <= _currentFilter.priceRange!.end)
                  .toList();
            }

            // Transmission
            if (_currentFilter.transmission != null &&
                _currentFilter.transmission != 'All') {
              cars = cars
                  .where((car) => car.transmissionType == _currentFilter.transmission)
                  .toList();
            }

            // Fuel Type
            if (_currentFilter.fuelType != null &&
                _currentFilter.fuelType != 'All') {
              cars = cars
                  .where((car) => car.fuelType == _currentFilter.fuelType)
                  .toList();
            }

            // Apply sorting
            if (_currentFilter.sortBy != null) {
              switch (_currentFilter.sortBy) {
                case 'Price: Low to High':
                  cars.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
                  break;
                case 'Price: High to Low':
                  cars.sort((a, b) => b.hourlyRate.compareTo(a.hourlyRate));
                  break;
              }
            } else {
              // Default sort by distance
              cars.sort((a, b) =>
                  _calculateDistance(a).compareTo(_calculateDistance(b)));
            }
            final filteredCars = cars;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filteredCars.length,
              itemBuilder: (context, index) {
                final car = filteredCars[index];
                final distance = _calculateDistance(car);
                return CarCardCompact(
                  car: car,
                  distanceInMeters: distance,
                  onBookNow: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (context) => FractionallySizedBox(heightFactor: 0.95),
                    );
                  },
                  onFavorite: () {},
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailsScreen(car: car),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
