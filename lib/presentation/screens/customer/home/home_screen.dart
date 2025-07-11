import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/common_widgets/brand_card.dart';
import '../../../../shared/common_widgets/car_card_grid.dart';
import '../../../../models/Firebase_car_model.dart';
import '../../../../models/customer models/rent model/car_brand_model.dart';
import '../../../../utils/ui/address_utils.dart';
import '../map_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import '../../../../core/services/car_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  final CarService _carService = CarService();
  List<CarModel> _allCars = [];
  bool _isLoading = true;

  LatLng? get _userLocation {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = authService.userData;
    final locData = userData != null ? userData['location'] : null;
    if (locData != null && locData is Map) {
      final lat = locData['latitude'];
      final lng = locData['longitude'];
      if (lat != null && lng != null) {
        return LatLng(lat.toDouble(), lng.toDouble());
      }
    }
    return null;
  }

  Future<void> _loadCarsData() async {
    setState(() => _isLoading = true);
    try {
      _allCars = await _carService.getCars();
    } catch (e) {
      print('Error loading cars: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAddressName();
    _loadCarsData();
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
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _fetchAddressName();
    await _loadCarsData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildLocationHeader(theme),
                      const SizedBox(height: 24),
                      _buildBrandsSection(theme),
                      const SizedBox(height: 24),
                      _buildFeaturedCarsSection(theme),
                    ],
                  ),
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

  String? _addressName;
  bool _isLoadingAddress = false;

  Future<void> _fetchAddressName() async {
    setState(() {
      _isLoadingAddress = true;
    });
    final authService = Provider.of<AuthService>(context, listen: false);
    final userData = authService.userData;
    final locData = userData != null ? userData['location'] : null;
    if (locData != null && locData is Map) {
      final lat = locData['latitude'];
      final lng = locData['longitude'];
      if (lat != null && lng != null) {
        final address = await AddressUtils.getAddressFromLatLng(
          lat.toDouble(),
          lng.toDouble(),
        );
        setState(() {
          _addressName = address;
          _isLoadingAddress = false;
        });
        return;
      }
    }
    setState(() {
      _addressName = 'Unknown Location';
      _isLoadingAddress = false;
    });
  }

  Widget _buildLocationHeader(ThemeData theme) {
    final userLoc = _userLocation;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/svg/location.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              _isLoadingAddress
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                  : Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      _addressName ?? 'Unknown Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => MapScreen(
                      cars: _allCars,
                      userLocation: userLoc ?? const LatLng(6.1164, 125.1716),
                    ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: SvgPicture.asset(
              'assets/svg/map-2.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandsSection(ThemeData theme) {
    // Hard-coded list of popular car brands
    final brands = [
      CarBrandModel(name: 'Audi', logo: 'assets/svg/audi.svg', count: 0),
      CarBrandModel(name: 'BMW', logo: 'assets/svg/bmw.svg', count: 0),
      CarBrandModel(name: 'Chevrolet', logo: 'assets/svg/chevrolet.svg', count: 0),
      CarBrandModel(name: 'Ford', logo: 'assets/svg/ford.svg', count: 0),
      CarBrandModel(name: 'Honda', logo: 'assets/svg/honda.svg', count: 0),
      CarBrandModel(name: 'Hyundai', logo: 'assets/svg/hyundai.svg', count: 0),
      CarBrandModel(name: 'Mazda', logo: 'assets/svg/mazda.svg', count: 0),
      CarBrandModel(name: 'Mitsubishi', logo: 'assets/svg/mitsubishi.svg', count: 0),
      CarBrandModel(name: 'Nissan', logo: 'assets/svg/nissan.svg', count: 0),
      CarBrandModel(name: 'Subaru', logo: 'assets/svg/subaru.svg', count: 0),
      CarBrandModel(name: 'Suzuki', logo: 'assets/svg/suzuki.svg', count: 0),
      CarBrandModel(name: 'Toyota', logo: 'assets/svg/toyota.svg', count: 0),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Car Brands',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90, // Increased from 80 to give more vertical space
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              vertical: 4,
            ), // Add vertical padding
            separatorBuilder:
                (context, index) =>
                    const SizedBox(width: 12), // Reduced from 16
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                ), // Add vertical padding to cards
                child: BrandCard(brand: brands[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCarsSection(ThemeData theme) {
    final userLoc = _userLocation;

    // Filter for available cars and sort them by distance
    var availableCars =
        _allCars
            .where(
              (car) => car.availabilityStatus == AvailabilityStatus.available,
            )
            .toList();

    if (userLoc != null) {
      availableCars.sort((a, b) {
        final distanceA =
            (a.location.containsKey('latitude') &&
                    a.location.containsKey('longitude'))
                ? Geolocator.distanceBetween(
                  userLoc.latitude,
                  userLoc.longitude,
                  a.location['latitude']!,
                  a.location['longitude']!,
                )
                : double.infinity;

        final distanceB =
            (b.location.containsKey('latitude') &&
                    b.location.containsKey('longitude'))
                ? Geolocator.distanceBetween(
                  userLoc.latitude,
                  userLoc.longitude,
                  b.location['latitude']!,
                  b.location['longitude']!,
                )
                : double.infinity;

        return distanceA.compareTo(distanceB);
      });
    }

    // Use a subset of cars for the featured section
    final featuredCars = availableCars.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Cars',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (featuredCars.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'No featured cars available.',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featuredCars.length,
            itemBuilder: (context, index) {
              final car = featuredCars[index];
              double? distanceInMeters;

              if (userLoc != null &&
                  car.location.containsKey('latitude') &&
                  car.location.containsKey('longitude')) {
                distanceInMeters = Geolocator.distanceBetween(
                  userLoc.latitude,
                  userLoc.longitude,
                  car.location['latitude']!,
                  car.location['longitude']!,
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: CarCardGrid(
                  car: car,
                  distanceInMeters: distanceInMeters,
                  onTap: () {
                    // Navigate to car details screen
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
