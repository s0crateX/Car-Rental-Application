import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../shared/common_widgets/car_card_compact.dart';
import '../../../../../shared/data/sample_cars.dart';
import '../../../../../shared/models/car_model.dart';
import 'car_filter_bottom_sheet.dart';
import 'car_details_screen.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showScrollToTop = false;

  List<CarModel> get _allCarsRaw => [
    ...SampleCars.getPopularCars(),
    ...SampleCars.getRecommendedCars(),
  ];

  CarFilter _filter = CarFilter();

  List<CarModel> get filteredCars {
    List<CarModel> cars = _allCarsRaw;
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      cars =
          cars
              .where(
                (car) =>
                    car.name.toLowerCase().contains(q) ||
                    car.type.toLowerCase().contains(q) ||
                    car.transmissionType.toLowerCase().contains(q) ||
                    car.fuelType.toLowerCase().contains(q) ||
                    car.seatsCount.toLowerCase().contains(q),
              )
              .toList();
    }
    // Car Type
    if (_filter.carType != null && _filter.carType != 'All') {
      cars = cars.where((car) => car.type == _filter.carType).toList();
    }
    // Price Range
    if (_filter.priceRange != null) {
      cars =
          cars
              .where(
                (car) =>
                    car.price >= _filter.priceRange!.start &&
                    car.price <= _filter.priceRange!.end,
              )
              .toList();
    }
    // Transmission
    if (_filter.transmission != null && _filter.transmission != 'All') {
      cars =
          cars
              .where((car) => car.transmissionType == _filter.transmission)
              .toList();
    }
    // Fuel Type
    if (_filter.fuelType != null && _filter.fuelType != 'All') {
      cars = cars.where((car) => car.fuelType == _filter.fuelType).toList();
    }
    // Sort By
    if (_filter.sortBy != null && _filter.sortBy != 'Default') {
      if (_filter.sortBy == 'Price: Low to High') {
        cars.sort((a, b) => a.price.compareTo(b.price));
      } else if (_filter.sortBy == 'Price: High to Low') {
        cars.sort((a, b) => b.price.compareTo(a.price));
      }
      // 'Newest' is omitted since CarModel has no year field.
    }
    return cars;
  }

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
                    _buildCategoriesSection(theme),
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
        // Removed border for a clean look
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
          GestureDetector(
            onTap: () async {
              final result = await showModalBottomSheet<CarFilter>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (context) => CarFilterBottomSheet(initialFilter: _filter),
              );
              if (result != null) {
                setState(() {
                  _filter = result;
                });
              }
            },
            child: SvgPicture.asset(
              'assets/svg/adjustments-horizontal.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.onSurface.withOpacity(0.7),
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(ThemeData theme) {
    final categories = [
      {'name': 'All', 'icon': 'assets/svg/checks.svg', 'isSelected': true},
      {'name': 'Sedan', 'icon': 'assets/svg/sedan.svg', 'isSelected': false},
      {'name': 'SUV', 'icon': 'assets/svg/suv.svg', 'isSelected': false},
      {
        'name': 'Hatchback',
        'icon': 'assets/svg/hatchback.svg',
        'isSelected': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              category['isSelected'] == true
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          category['icon'] as String,
                          width: 32,
                          height: 32,
                          colorFilter: ColorFilter.mode(
                            category['isSelected'] == true
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllCarsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Cars',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
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
            return CarCardCompact(
              car: car,
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
        ),
      ],
    );
  }
}
