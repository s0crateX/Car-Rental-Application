import 'package:flutter/material.dart';
import 'owner_home_screen_new.dart';

class OwnerNavScreen extends StatefulWidget {
  const OwnerNavScreen({Key? key}) : super(key: key);

  @override
  State<OwnerNavScreen> createState() => _OwnerNavScreenState();
}

class _OwnerNavScreenState extends State<OwnerNavScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    OwnerHomeScreen(),
    // Add more screens here as needed, e.g. MyCarsScreen(), OwnerProfileScreen(), etc.
    Center(child: Text('Other Tab (Placeholder)')),
  ];

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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Other',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: _onItemTapped,
      ),
    );
  }
}
