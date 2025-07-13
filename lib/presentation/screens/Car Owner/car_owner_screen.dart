import 'package:flutter/material.dart';
import 'bookings/owner_bookings_screen.dart';
import 'home/owner_home_screen_new.dart';
import 'my_cars/owner_my_cars_screen.dart';
import 'profile/owner_profile_screen.dart';
import '../../../utils/animations/car_owner_navbar.dart';

class CarOwnerScreen extends StatefulWidget {
  const CarOwnerScreen({super.key});

  @override
  State<CarOwnerScreen> createState() => _CarOwnerScreenState();
}

class _CarOwnerScreenState extends State<CarOwnerScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      OwnerHomeScreen(onNavigateToBookings: _onItemTapped),
      const OwnerBookingsScreen(),
      const OwnerMyCarsScreen(),
      const OwnerProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: AnimatedUnderlineNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
