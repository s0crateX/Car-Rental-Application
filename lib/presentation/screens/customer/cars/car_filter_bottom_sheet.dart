import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CarFilter {
  String? carType;
  RangeValues? priceRange;
  String? transmission;
  String? fuelType;
  String? sortBy;
  double? maxDistance;

  CarFilter({
    this.carType,
    this.priceRange,
    this.transmission,
    this.fuelType,
    this.sortBy,
    this.maxDistance,
  });
}

class CarFilterBottomSheet extends StatefulWidget {
  final CarFilter initialFilter;
  final void Function(CarFilter)? onApply;

  const CarFilterBottomSheet({
    super.key,
    required this.initialFilter,
    this.onApply,
  });

  @override
  State<CarFilterBottomSheet> createState() => _CarFilterBottomSheetState();
}

class _CarFilterBottomSheetState extends State<CarFilterBottomSheet> {
  late CarFilter _filter;

  final List<String> carTypes = ['All', 'Sedan', 'SUV', 'Hatchback', 'Luxury'];
  final List<String> transmissions = ['All', 'Automatic', 'Manual'];
  final List<String> fuelTypes = [
    'All',
    'Petrol',
    'Diesel',
    'Electric',
    'Hybrid',
  ];
  final List<String> sortByOptions = [
    'Default',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
  ];

  RangeValues priceRange = const RangeValues(10, 500);

  double _distanceKm = 20;

  @override
  void initState() {
    super.initState();
    _filter = CarFilter(
      carType: widget.initialFilter.carType ?? 'All',
      priceRange: widget.initialFilter.priceRange ?? const RangeValues(10, 500),
      transmission: widget.initialFilter.transmission ?? 'All',
      fuelType: widget.initialFilter.fuelType ?? 'All',
      sortBy: widget.initialFilter.sortBy ?? 'Default',
      maxDistance: widget.initialFilter.maxDistance ?? 20,
    );
    priceRange = _filter.priceRange!;
    _distanceKm = _filter.maxDistance ?? 20;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/filter.svg',
                    height: 24,
                    width: 24,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter Cars',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDropdown(
                'Car Type',
                carTypes,
                _filter.carType!,
                (val) => setState(() => _filter.carType = val),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/peso.svg',
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Price Range (₱${priceRange.start.toInt()} - ₱${priceRange.end.toInt()})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: RangeSlider(
                  values: priceRange,
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  labels: RangeLabels(
                    '₱${priceRange.start.toInt()}',
                    '₱${priceRange.end.toInt()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      priceRange = values;
                      _filter.priceRange = values;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                  inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.place, color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Show cars within ${_distanceKm.round()} km',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _distanceKm,
                min: 1,
                max: 2000, // update this if needed.default is 100km
                divisions: 99, // update this if needed.default is 99
                label: '${_distanceKm.round()} km',
                onChanged:
                    (v) => setState(() {
                      _distanceKm = v;
                      _filter.maxDistance = v;
                    }),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Transmission',
                transmissions,
                _filter.transmission!,
                (val) => setState(() => _filter.transmission = val),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Fuel Type',
                fuelTypes,
                _filter.fuelType!,
                (val) => setState(() => _filter.fuelType = val),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Sort By',
                sortByOptions,
                _filter.sortBy!,
                (val) => setState(() => _filter.sortBy = val),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _filter = CarFilter(
                            carType: 'All',
                            priceRange: const RangeValues(10, 500),
                            transmission: 'All',
                            fuelType: 'All',
                            sortBy: 'Default',
                            maxDistance: 20,
                          );
                          priceRange = _filter.priceRange!;
                          _distanceKm = _filter.maxDistance!;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/adjustments-horizontal.svg',
                            height: 18,
                            width: 18,
                            colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Reset',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _filter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Apply',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String value,
    ValueChanged<String> onChanged,
  ) {
    final theme = Theme.of(context);
    String iconPath;

    switch (label) {
      case 'Car Type':
        iconPath = 'assets/svg/car.svg';
        break;
      case 'Transmission':
        iconPath =
            value == 'Automatic'
                ? 'assets/svg/automatic-gearbox.svg'
                : 'assets/svg/manual-gearbox.svg';
        break;
      case 'Fuel Type':
        iconPath = 'assets/svg/gas-station.svg';
        break;
      case 'Sort By':
        iconPath = 'assets/svg/arrow-down.svg';
        break;
      default:
        iconPath = 'assets/svg/settings.svg';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: 20,
              width: 20,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.secondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: SvgPicture.asset(
                'assets/svg/chevron-compact-down.svg',
                height: 18,
                width: 18,
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              borderRadius: BorderRadius.circular(12),
              items:
                  options
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                              fontWeight:
                                  e == value
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}
