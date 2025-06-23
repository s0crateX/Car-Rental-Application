import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
import '../../../../core/authentication/auth_service.dart';
import '../../../../shared/common_widgets/snackbars/error_snackbar.dart';
import 'owner_edit_profile_screen.dart';
import 'widgets/owner_profile_menu_item.dart';
import 'owner_document_verification_screen.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Optionally refresh profile data here if needed
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
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
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Consumer<AuthService>(
                      builder: (context, authService, _) {
                        final userData = authService.userData;
                        final profileImageUrl =
                            userData?['profileImageUrl'] as String?;
                        return Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.mediumBlue,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.navy.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(55),
                            child:
                                profileImageUrl != null &&
                                        profileImageUrl.isNotEmpty
                                    ? Image.network(
                                      profileImageUrl,
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.cover,
                                    )
                                    : Container(
                                      color: AppTheme.navy,
                                      child: SvgPicture.asset(
                                        'assets/svg/user.svg',
                                        width: 10,
                                        height: 10,
                                        colorFilter: ColorFilter.mode(
                                          AppTheme.lightBlue,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Show car owner name directly under the profile icon
                    Consumer<AuthService>(
                      builder: (context, authService, _) {
                        final userData = authService.userData;
                        final fullName = (userData != null && userData['fullName'] != null && (userData['fullName'] as String).trim().isNotEmpty)
                            ? userData['fullName'] as String
                            : 'Car Owner';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                          child: Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.lightBlue,
                            ),
                          ),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => const OwnerEditProfileScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppTheme.lightBlue,
                        foregroundColor: AppTheme.navy,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'General Sans',
                        ),
                      ),
                      icon: SvgPicture.asset(
                        'assets/svg/edit.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          AppTheme.navy,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: const Text('Edit Profile'),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              OwnerProfileMenuItem(
                icon: 'assets/svg/note.svg',
                title: 'Upload Documents',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => const OwnerDocumentVerificationScreen(),
                    ),
                  );
                },
              ),
              OwnerProfileMenuItem(
                icon: 'assets/svg/lock.svg',
                title: 'Log out',
                onTap: () => _showLogoutConfirmationDialog(context),
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
}
