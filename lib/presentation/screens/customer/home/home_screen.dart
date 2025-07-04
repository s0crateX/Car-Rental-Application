import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../shared/common_widgets/car_card.dart';
import '../../../../shared/common_widgets/brand_card.dart';
import '../../../../shared/models/Final Model/Firebase_car_model.dart';
import '../../../../shared/models/Final Model/car_brand_model.dart';
import '../../../../utils/ui/address_utils.dart';
import '../map_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../../core/authentication/auth_service.dart';
import 'package:geolocator/geolocator.dart';
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
  String _selectedLocationOption = 'Current Location';

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

  List<CarModel> _nearbyCars = [];

  Future<void> _loadCarsData() async {
    setState(() => _isLoading = true);
    try {
      final userLoc = _userLocation;

      if (userLoc != null) {
        // Get cars near user location
        _nearbyCars = await _carService.getNearbyCars(
          userLoc,
          maxDistanceKm: 20000.0,
        );
        _allCars = await _carService.getCars();
      } else {
        // If no user location, just get all cars
        _allCars = await _carService.getCars();
        _nearbyCars = _allCars;
      }
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

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      // Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, show a message
          setState(() {
            _addressName = 'Location permissions are denied';
            _isLoadingAddress = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied
        setState(() {
          _addressName = 'Location permissions are permanently denied';
          _isLoadingAddress = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update user location directly in Firestore
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.user != null) {
        await authService.updateUserProfileData({
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          }
        });
      }

      // Get address from coordinates
      final address = await AddressUtils.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      // Update state
      setState(() {
        _addressName = address;
        _isLoadingAddress = false;
      });

      // Reload cars based on new location
      _loadCarsData();
    } catch (e) {
      setState(() {
        _addressName = 'Error getting location: $e';
        _isLoadingAddress = false;
      });
    }
  }

  void _showLocationBottomSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Where should we deliver your order?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLocationOption(
                theme,
                'Use my current location',
                Icons.my_location,
              ),
              const Divider(height: 1),
              _buildSavedLocationOption(
                theme,
                'Address',
                '${_addressName ?? 'Unknown Location'}',
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to add new address screen
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add a new address'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.lightBlue,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationHeader(ThemeData theme) {
    final userLoc = _userLocation;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              _showLocationBottomSheet(context, theme);
            },
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MapScreen(
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

  Widget _buildLocationOption(ThemeData theme, String option, IconData icon) {
    final bool isSelected = _selectedLocationOption == option;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLocationOption = option;
        });
        Navigator.pop(context);

        // Handle location change based on selection
        if (option == 'Use my current location') {
          _getCurrentLocation();
        } else if (option == 'Choose Location') {
          // Navigate to map screen for location selection
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MapScreen(
                cars: _nearbyCars,
                userLocation:
                    _userLocation ?? const LatLng(6.1164, 125.1716),
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected
                        ? AppTheme.mediumBlue.withOpacity(0.3)
                        : AppTheme.navy.withOpacity(0.5),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppTheme.lightBlue : AppTheme.paleBlue,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.white,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.radio_button_checked,
                size: 24,
                color: AppTheme.lightBlue,
              ),
            if (!isSelected)
              Icon(
                Icons.radio_button_unchecked,
                size: 24,
                color: AppTheme.paleBlue,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedLocationOption(
    ThemeData theme,
    String title,
    String subtitle,
  ) {
    final bool isSelected = _selectedLocationOption == title;
    // isSelected is used for Radio value and styling

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLocationOption = title;
          Navigator.pop(context);
          // Use the saved location
          _addressName = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Radio<String>(
              value: title,
              groupValue: _selectedLocationOption,
              onChanged: (value) {
                setState(() {
                  _selectedLocationOption = value!;
                  Navigator.pop(context);
                  _addressName = title;
                });
              },
              activeColor: AppTheme.lightBlue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: AppTheme.paleBlue),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () {
                // Edit address functionality
                Navigator.pop(context);
              },
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandsSection(ThemeData theme) {
    // Hard-coded list of popular car brands
    final brands = [
      CarBrandModel(
        name: 'Toyota',
        logo: 'assets/svg/toyota-logo.svg',
        count: 12,
      ),
      CarBrandModel(name: 'Honda', logo: 'assets/svg/honda-logo.svg', count: 8),
      CarBrandModel(name: 'BMW', logo: 'assets/svg/bmw-logo.svg', count: 6),
      CarBrandModel(
        name: 'Mercedes',
        logo: 'assets/svg/mercedes-logo.svg',
        count: 5,
      ),
      CarBrandModel(name: 'Ford', logo: 'assets/svg/ford-logo.svg', count: 4),
    ];

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
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (cars.isEmpty)
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
