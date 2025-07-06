import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomerNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomerNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      {'icon': 'assets/svg/home.svg', 'label': 'Home'},
      {'icon': 'assets/svg/steering-wheel.svg', 'label': 'Cars'},
      {'icon': 'assets/svg/booking.svg', 'label': 'Bookings'},
      {'icon': 'assets/svg/profile.svg', 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,

      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onItemTapped(index),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 250),
                    curve: Curves.ease,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          items[index]['icon'] as String,
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.unselectedWidgetColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[index]['label'] as String,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.unselectedWidgetColor,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 250),
                          margin: const EdgeInsets.only(top: 4),
                          height: 3,
                          width: isSelected ? 28 : 0,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
