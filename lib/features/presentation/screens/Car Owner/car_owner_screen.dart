import 'package:flutter/material.dart';
import 'bookings/owner_bookings_screen.dart';
import 'home/owner_home_screen_new.dart';
import 'my_cars/owner_my_cars_screen.dart';
import 'profile/owner_profile_screen.dart';
import 'navbar.dart';

class CarOwnerScreen extends StatefulWidget {
  const CarOwnerScreen({Key? key}) : super(key: key);

  @override
  _CarOwnerScreenState createState() => _CarOwnerScreenState();
}

class _CarOwnerScreenState extends State<CarOwnerScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    OwnerHomeScreen(),
    OwnerBookingsScreen(),
    OwnerMyCarsScreen(),
    OwnerProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: AnimatedUnderlineNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
