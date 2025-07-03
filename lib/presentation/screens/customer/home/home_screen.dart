import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/common_widgets/car_card.dart';
import '../../../../shared/common_widgets/brand_card.dart';
import '../../../../shared/data/sample_cars.dart';
import '../../../../shared/data/sample_brands.dart';
import '../../../../shared/models/Mock Model/car_model.dart';
import '../../../../utils/ui/address_utils.dart';
import '../map_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  List<CarModel> get _allCars => SampleCars.getPopularCars();

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

  List<CarModel> get _nearbyCars {
    final userLoc = _userLocation;
    if (userLoc == null) return _allCars;
    const double maxDistanceKm =
        20000.0; // Car near to the user location, max 20km
    final Distance distance = Distance();
    final carsWithDistance =
        _allCars
            .where((car) => car.location != null)
            .map((car) {
              final carLoc = car.location!;
              final dist = distance.as(LengthUnit.Kilometer, userLoc, carLoc);
              return {'car': car, 'distance': dist};
            })
            .where((entry) => (entry['distance'] as double) <= maxDistanceKm)
            .toList();
    carsWithDistance.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );
    return carsWithDistance.map((entry) => entry['car'] as CarModel).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchAddressName();
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
    setState(() {}); // Force rebuild to update UI (if needed)
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
                      _buildPopularCarsSection(theme),
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
                      cars: _nearbyCars,
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
    final brands = SampleBrands.getBrands();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Brands',
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

  Widget _buildPopularCarsSection(ThemeData theme) {
    final cars = _nearbyCars;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cars Near You',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        if (cars.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'No cars found near your location.',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: cars.length,
            separatorBuilder: (context, index) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              return CarCard(
                car: cars[index],
                onBookNow: () {},
                onFavorite: () {},
              );
            },
          ),
      ],
    );
  }
}
