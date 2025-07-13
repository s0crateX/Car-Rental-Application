import 'package:flutter/material.dart';
import 'owner_home_screen_new.dart';

class OwnerNavScreen extends StatefulWidget {
  const OwnerNavScreen({super.key});

  @override
  State<OwnerNavScreen> createState() => _OwnerNavScreenState();
}

class _OwnerNavScreenState extends State<OwnerNavScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      OwnerHomeScreen(onNavigateToBookings: _onItemTapped),
      // Add more screens here as needed, e.g. MyCarsScreen(), OwnerProfileScreen(), etc.
      const Center(child: Text('Other Tab (Placeholder)')),
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
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Other'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}
