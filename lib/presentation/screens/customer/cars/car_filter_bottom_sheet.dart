import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:car_rental_app/shared/data/car_types.dart';

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

  final List<String> carTypes = ['All', ...CarTypes.allTypes.toSet()];
  final List<String> transmissions = ['All', 'Automatic', 'Manual'];
  final List<String> fuelTypes = [
    'All',
    'Gasoline',
    'Unleaded',
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

  RangeValues priceRange = const RangeValues(10, 10000);

  double _distanceKm = 20;

  @override
  void initState() {
    super.initState();
    _filter = CarFilter(
      carType: widget.initialFilter.carType ?? 'All',
      priceRange:
          widget.initialFilter.priceRange ?? const RangeValues(10, 10000),
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
    return Container(
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
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                    'Price Range',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₱${priceRange.start.round()} - ₱${priceRange.end.round()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveTrackColor: theme.colorScheme.primary.withOpacity(
                    0.2,
                  ),
                  thumbColor: theme.colorScheme.primary,
                  overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                  valueIndicatorColor: theme.colorScheme.primary,
                  valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                ),
                child: RangeSlider(
                  min: 10,
                  max: 10000,
                  divisions: 49,
                  labels: RangeLabels(
                    '₱${priceRange.start.round()}',
                    '₱${priceRange.end.round()}',
                  ),
                  values: priceRange,
                  onChanged: (values) {
                    setState(() {
                      priceRange = values;
                      _filter.priceRange = values;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/location.svg',
                    height: 20,
                    width: 20,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.secondary,
                      BlendMode.srcIn,
                    ),
                  ),
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
                min: 1,
                max: 100,
                divisions: 99,
                label: '${_distanceKm.round()} km',
                value: _distanceKm,
                onChanged: (value) {
                  setState(() {
                    _distanceKm = value;
                    _filter.maxDistance = value;
                  });
                },
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
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Pop with a new, empty CarFilter object to signify a reset.
                        Navigator.pop(context, CarFilter());
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
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              elevation: 0,
              dropdownColor: theme.colorScheme.surface,
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
                  options.map((e) {
                final seats = CarTypes.seatsPerType[e];
                return DropdownMenuItem(
                  value: e,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e,
                        style: TextStyle(
                          fontWeight:
                              e == value ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (seats != null)
                        Text(
                          seats,
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
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
