import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/widgets/car_card.dart';
import 'package:car_rental_app/widgets/login_signup_popup.dart';
import 'package:car_rental_app/models/car_model.dart';

class ScoutScreen extends StatefulWidget {
  const ScoutScreen({Key? key}) : super(key: key);

  @override
  State<ScoutScreen> createState() => _ScoutScreenState();
}

class _ScoutScreenState extends State<ScoutScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showLoginPopup = false;
  String _selectedFilter = 'Low to Expensive';

  final List<String> _filterOptions = [
    'Low to Expensive',
    'Expensive to Low',
    'Top Rating',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Show login popup when user scrolls down a bit
    if (_scrollController.offset > 200 && !_showLoginPopup) {
      setState(() {
        _showLoginPopup = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.mediumBlue, // Use themed background
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.darkNavy.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ), // More compact
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 32,
                    height: 3,
                    margin: const EdgeInsets.only(top: 6, bottom: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.lightBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    'Sort by',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkNavy,
                    ),
                  ),
                ),
                ..._filterOptions.map(
                  (option) => InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      setState(() {
                        _selectedFilter = option;
                        // TODO: Implement sorting logic
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            _selectedFilter == option
                                ? AppTheme.darkNavy.withOpacity(0.12)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: option,
                            groupValue: _selectedFilter,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedFilter = value!;
                                // TODO: Implement sorting logic
                              });
                              Navigator.pop(context);
                            },
                            activeColor: AppTheme.darkNavy,
                            fillColor: MaterialStateProperty.all(
                              AppTheme.darkNavy,
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              option,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.darkNavy,
                                fontWeight:
                                    _selectedFilter == option
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: SafeArea(
        child: Stack(
          children: [
            // Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: AppTheme.darkNavy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with premium design
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Selection',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dummyCars.length} luxury vehicles available',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.paleBlue),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.sort_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: _showSortBottomSheet,
                            tooltip: 'Sort vehicles',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Car grid
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.darkNavy.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 20.0,
                          ),
                      itemCount: dummyCars.length,
                      itemBuilder: (context, index) {
                        return CarCard(car: dummyCars[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Login/Signup popup
            if (_showLoginPopup) const LoginSignupPopup(),
          ],
        ),
      ),
    );
  }
}

// Dummy data for testing
final List<Car> dummyCars = [
  Car(
    id: '1',
    brand: 'Alfa Romeo',
    model: 'Giulia',
    variant: 'Veloce',
    year: 2024,
    pricePerHour: 23.30,
    imageUrl: 'https://placeholder.com/car1',
    status: CarStatus.available,
    isNew: true,
  ),
  Car(
    id: '2',
    brand: 'Alfa Romeo',
    model: 'Giulia',
    variant: 'Competizione',
    year: 2024,
    pricePerHour: 20.10,
    imageUrl: 'https://placeholder.com/car2',
    status: CarStatus.available,
    bookingEndTime: '10 PM',
  ),
  Car(
    id: '3',
    brand: 'Alfa Romeo',
    model: 'Giulia',
    variant: 'Sprint',
    year: 2024,
    pricePerHour: 22.00,
    imageUrl: 'https://placeholder.com/car3',
    status: CarStatus.available,
  ),
  Car(
    id: '4',
    brand: 'Alfa Romeo',
    model: 'Giulia',
    variant: 'Quadrifoglio',
    year: 2023,
    pricePerHour: 21.30,
    imageUrl: 'https://placeholder.com/car4',
    status: CarStatus.booked,
    bookingEndTime: '5 PM',
  ),
  Car(
    id: '5',
    brand: 'Alfa Romeo',
    model: 'Giulia',
    variant: 'Sprint Rear Wheel Drive',
    year: 2024,
    pricePerHour: 29.50,
    imageUrl: 'https://placeholder.com/car5',
    status: CarStatus.available,
  ),
  Car(
    id: '1',
    brand: 'Alfa Romeo',
    model: 'Giulia',
    variant: 'Veloce',
    year: 2024,
    pricePerHour: 23.30,
    imageUrl: 'https://placeholder.com/car1',
    status: CarStatus.available,
    isNew: true,
  ),
  Car(
    id: '2',
    brand: 'Alfa Romeo',
    model: 'Giulia',
    variant: 'Competizione',
    year: 2024,
    pricePerHour: 20.10,
    imageUrl: 'https://placeholder.com/car2',
    status: CarStatus.booked,
    bookingEndTime: '10 PM',
  ),
  Car(
    id: '3',
    brand: 'Alfa Romeo',
    model: 'Giulia',
    variant: 'Sprint',
    year: 2024,
    pricePerHour: 22.00,
    imageUrl: 'https://placeholder.com/car3',
    status: CarStatus.available,
  ),
  Car(
    id: '4',
    brand: 'Alfa Romeo',
    model: 'Giulia',
    variant: 'Quadrifoglio',
    year: 2023,
    pricePerHour: 21.30,
    imageUrl: 'https://placeholder.com/car4',
    status: CarStatus.booked,
    bookingEndTime: '5 PM',
  ),
  Car(
    id: '5',
    brand: 'Alfa Romeo',
    model: 'Giulia',
    variant: 'Sprint Rear Wheel Drive',
    year: 2024,
    pricePerHour: 29.50,
    imageUrl: 'https://placeholder.com/car5',
    status: CarStatus.available,
  ),
];
