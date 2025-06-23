import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddCarButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddCarButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.navy,
              AppTheme.navy.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.mediumBlue.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppTheme.lightBlue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.mediumBlue.withOpacity(0.3),
                    AppTheme.lightBlue.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/svg/plus.svg',
                width: 24,
                height: 24,
                color: AppTheme.lightBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add New Car',
              style: TextStyle(
                color: AppTheme.lightBlue,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'General Sans',
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
