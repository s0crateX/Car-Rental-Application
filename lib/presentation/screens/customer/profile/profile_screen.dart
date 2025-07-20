import 'package:car_rental_app/presentation/screens/customer/profile/edit_profile_screen.dart';
import 'package:car_rental_app/presentation/screens/customer/profile/document_verification_screen.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/config/routes.dart';
import 'package:car_rental_app/presentation/screens/customer/profile/location_selection_screen.dart';
import 'package:car_rental_app/shared/common_widgets/snackbars/error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signOut();
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    ErrorSnackbar.show(context: context, message: 'Logged out successfully');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Optionally refresh profile data here if needed
  }

  Future<void> _refreshProfile(BuildContext context) async {
    try {
      await Provider.of<AuthService>(context, listen: false).refreshUserData();
      setState(() {});
    } catch (e) {
      ErrorSnackbar.show(
        context: context,
        message: 'Failed to refresh profile.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => _refreshProfile(context),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Consumer<AuthService>(
                      builder: (context, authService, _) {
                        final userData = authService.userData;
                        final profileImageUrl =
                            userData?['profileImageUrl'] as String?;
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.white,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child:
                                profileImageUrl != null &&
                                        profileImageUrl.isNotEmpty
                                    ? Image.network(
                                      profileImageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: AppTheme.navy,
                                          child: const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: AppTheme.paleBlue,
                                          ),
                                        );
                                      },
                                    )
                                    : Container(
                                      color: AppTheme.navy,
                                      child: const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppTheme.white,
                                      ),
                                    ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Consumer<AuthService>(
                      builder: (context, authService, _) {
                        final userData = authService.userData;
                        final name = userData?['fullName'] ?? 'No Name';
                        final email = userData?['email'] ?? 'No Email';
                        return Column(
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.paleBlue,
                              ),
                            ),
                          ],
                        );
                      },
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
                        minimumSize: const Size(120, 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Edit Profile', style: TextStyle(color: AppTheme.darkNavy),),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
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
                onTap: _showLogoutConfirmationDialog,
                titleColor: Colors.red,
                iconColor: Colors.red,
                chevronColor: Colors.red,
              ),
              const SizedBox(height: 40),
            ],
          ),
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
