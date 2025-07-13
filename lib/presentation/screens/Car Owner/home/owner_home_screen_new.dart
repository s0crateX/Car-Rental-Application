import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/models/car%20owner%20%20models/booking%20model/rent.dart';
import 'package:car_rental_app/presentation/screens/Car%20Owner/bookings/widgets/booking_info_card.dart';
import 'package:car_rental_app/presentation/screens/Car%20Owner/home/widgets/widgets.dart';
import 'package:provider/provider.dart';

class OwnerHomeScreen extends StatefulWidget {
  final Function(int) onNavigateToBookings;
  const OwnerHomeScreen({super.key, required this.onNavigateToBookings});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _totalCars = 0;
  int _rentedCars = 0;
  int _reservations = 0;
  int _completedRentals = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchCarCount(),
      _fetchRentedCarCount(),
      _fetchReservationCount(),
      _fetchCompletedRentalsCount(),
    ]);
  }

  Future<void> _fetchRentedCarCount() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    if (user == null) return;

    // 1. Get all car IDs owned by the current user
    final carsSnapshot = await FirebaseFirestore.instance
        .collection('Cars')
        .where('carOwnerDocumentId', isEqualTo: user.uid)
        .get();

    if (carsSnapshot.docs.isEmpty) {
      if (mounted) {
        setState(() {
          _rentedCars = 0;
        });
      }
      return;
    }

    final carIds = carsSnapshot.docs.map((doc) => doc.id).toList();

    // 2. Count approved rentals for those cars with 'rentNow' booking type
    final rentApproveSnapshot = await FirebaseFirestore.instance
        .collection('rent_approve')
        .where('carId', whereIn: carIds)
        .where('bookingType', isEqualTo: 'rentNow')
        .get();

    if (mounted) {
      setState(() {
        _rentedCars = rentApproveSnapshot.docs.length;
      });
    }
  }

  Future<void> _fetchReservationCount() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    if (user == null) return;

    final carsSnapshot = await FirebaseFirestore.instance
        .collection('Cars')
        .where('carOwnerDocumentId', isEqualTo: user.uid)
        .get();

    if (carsSnapshot.docs.isEmpty) {
      if (mounted) {
        setState(() {
          _reservations = 0;
        });
      }
      return;
    }

    final carIds = carsSnapshot.docs.map((doc) => doc.id).toList();

    final rentApproveSnapshot = await FirebaseFirestore.instance
        .collection('rent_approve')
        .where('carId', whereIn: carIds)
        .where('bookingType', isEqualTo: 'reserve')
        .get();

    if (mounted) {
      setState(() {
        _reservations = rentApproveSnapshot.docs.length;
      });
    }
  }

  Future<void> _fetchCompletedRentalsCount() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    if (user == null) return;

    final carsSnapshot = await FirebaseFirestore.instance
        .collection('Cars')
        .where('carOwnerDocumentId', isEqualTo: user.uid)
        .get();

    if (carsSnapshot.docs.isEmpty) {
      if (mounted) {
        setState(() {
          _completedRentals = 0;
        });
      }
      return;
    }

    final carIds = carsSnapshot.docs.map((doc) => doc.id).toList();

    final rentCompletedSnapshot = await FirebaseFirestore.instance
        .collection('rent_completed')
        .where('carId', whereIn: carIds)
        .get();

    if (mounted) {
      setState(() {
        _completedRentals = rentCompletedSnapshot.docs.length;
      });
    }
  }

  Future<void> _fetchCarCount() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('Cars')
          .where('carOwnerDocumentId', isEqualTo: user.uid)
          .get();
      if (mounted) {
        setState(() {
          _totalCars = snapshot.docs.length;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          child: CustomScrollView(
            slivers: [
              // Summary Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          SummaryCard(
                            title: 'Total Cars',
                            count: _totalCars,
                            iconPath: 'assets/svg/car2.svg',
                            color: AppTheme.mediumBlue,
                          ),
                          SummaryCard(
                            title: 'Rented Cars',
                            count: _rentedCars,
                            iconPath: 'assets/svg/car-rental2.svg',
                            iconColor: AppTheme.white,
                            color: const Color(0xFF10B981), // Green
                          ),
                          SummaryCard(
                            title: 'Reservation',
                            count: _reservations,
                            iconPath: 'assets/svg/calendar-check.svg',
                            color: const Color(0xFFF59E0B), // Amber
                          ),
                          SummaryCard(
                            title: 'Completed',
                            count: _completedRentals,
                            iconPath: 'assets/svg/checks.svg',
                            color: const Color(0xFF0D9488), // Teal
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _buildRentalRequests(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRentalRequests() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.user;
    if (user == null) {
      return const SliverToBoxAdapter(
        child: Center(child: Text('Please log in to see requests.')),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rent_request')
          .where('ownerId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
              child: Center(child: Text('Error: ${snapshot.error}')));
        }

        final requests = snapshot.data?.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Rent.fromMap(data..['id'] = doc.id);
            }).toList() ??
            [];

        return SliverList(
          delegate: SliverChildListDelegate(
            [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rental Requests',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateToBookings(1),
                      child: const Text('View all'),
                    )
                  ],
                ),
              ),
              if (requests.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Text('No pending rental requests.'),
                  ),
                )
              else
                ...requests.map((rent) {
                  return BookingInfoCard(
                    rent: rent,
                    isRequest: true,
                    isCarOwner: true,
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
