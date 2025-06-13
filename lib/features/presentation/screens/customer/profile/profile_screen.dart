import 'package:car_rental_app/features/presentation/screens/customer/profile/edit_profile_screen.dart';
import 'package:car_rental_app/features/presentation/screens/customer/profile/document_verification_screen.dart';
import 'package:car_rental_app/features/presentation/screens/customer/profile/location_selection_screen.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../config/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with image and name
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.mediumBlue, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        'assets/images/profile_placeholder.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.navy,
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: AppTheme.paleBlue,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dave Cruz',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'davecruz@gmail.com',
                    style: TextStyle(fontSize: 14, color: AppTheme.lightBlue),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Profile menu items
            _buildProfileMenuItem(
              context,
              icon: 'assets/svg/location.svg',
              title: 'Location',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationSelectionScreen(),
                  ),
                );
              },
            ),
            _buildProfileMenuItem(
              context,
              icon: 'assets/svg/note.svg',
              title: 'Required Documents',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DocumentVerificationScreen(),
                  ),
                );
              },
            ),
            _buildProfileMenuItem(
              context,
              icon: 'assets/svg/lock.svg',
              title: 'Log out',
              onTap: () {
                ErrorSnackbar.show(
                  context: context,
                  message: 'Logged out successfully',
                );
              },
              titleColor: Colors.red,
              iconColor: Colors.red,
              chevronColor: Colors.red,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    Color? chevronColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.navy.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.navy,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    iconColor ?? AppTheme.lightBlue,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? AppTheme.white,
                ),
              ),
              const Spacer(),
              SvgPicture.asset(
                'assets/svg/chevron-compact-right.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  chevronColor ?? AppTheme.lightBlue,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
