import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/widgets/car_card.dart';
import 'package:car_rental_app/widgets/login_signup_popup.dart';
import 'package:car_rental_app/models/car_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sort by',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._filterOptions
                        .map(
                          (option) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Radio<String>(
                              value: option,
                              groupValue: _selectedFilter,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedFilter = value!;
                                  // TODO: Implement sorting logic
                                });
                                Navigator.pop(context);
                              },
                              activeColor: AppTheme.lightBlue,
                            ),
                            title: Text(
                              option,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.darkNavy,
                                fontWeight:
                                    _selectedFilter == option
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedFilter = option;
                                // TODO: Implement sorting logic
                              });
                              Navigator.pop(context);
                            },
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Count available cars
    final availableCars =
        dummyCars.where((car) => car.status == CarStatus.available).length;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Fixed header section
                Container(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with total available cars and sort button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${dummyCars.length} cars to rent',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          // Modern sort button
                          GestureDetector(
                            onTap: _showSortBottomSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.lightBlue.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.lightBlue.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tune,
                                    color: AppTheme.lightBlue,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Sort',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.lightBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scrollable car listings
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkNavy.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12.0),
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 12.0,
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
              ],
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
