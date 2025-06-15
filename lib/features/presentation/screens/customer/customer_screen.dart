import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'cars/cars_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    CarsScreen(),
    Center(
      child: Text(
        'Bookings',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    ),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<String> _svgIcons = [
    'assets/svg/home.svg',
    'assets/svg/steering-wheel.svg',
    'assets/svg/book.svg',
    'assets/svg/user-circle.svg',
  ];

  final List<String> _labels = ['Home', 'Cars', 'Bookings', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: PhysicalModel(
        color: Colors.transparent,
        elevation: 8,
        shadowColor: theme.colorScheme.primary.withOpacity(0.10),
        child: Container(
          decoration: BoxDecoration(color: theme.colorScheme.surface),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_svgIcons.length, (index) {
              final bool isActive = _selectedIndex == index;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _onItemTapped(index),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        SvgPicture.asset(
                          _svgIcons[index],
                          width: 26,
                          height: 26,
                          colorFilter: ColorFilter.mode(
                            isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _labels[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w400,
                            color:
                                isActive
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.ease,
                          height: 4,
                          width: isActive ? 32 : 0,
                          decoration: BoxDecoration(
                            color:
                                isActive
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
