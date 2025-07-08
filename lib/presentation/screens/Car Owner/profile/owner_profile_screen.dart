import 'package:car_rental_app/presentation/screens/Car%20Owner/profile/document_verification_Carowner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
import '../../../../core/authentication/auth_service.dart';
import '../../../../shared/common_widgets/snackbars/error_snackbar.dart';
import 'owner_edit_profile_screen.dart';
import 'widgets/owner_profile_menu_item.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  Map<String, dynamic>? _ownerData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchOwnerData();
  }

  Future<void> _fetchOwnerData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final uid = authService.user?.uid;
    if (uid == null) return;
    setState(() {
      _loading = true;
    });
    try {
      // Fetch from users collection instead of car_owners
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        _ownerData = doc.data();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

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
    // This will sign out the user and clear the session (autologin) via AuthService
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
        onRefresh: () async {
          await _fetchOwnerData();
          await _refreshProfile(context);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    _loading
                        ? const CircularProgressIndicator()
                        : Container(
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
                                _ownerData != null &&
                                        _ownerData!['profileImageUrl'] !=
                                            null &&
                                        (_ownerData!['profileImageUrl']
                                                as String)
                                            .isNotEmpty
                                    ? Image.network(
                                      _ownerData!['profileImageUrl'],
                                      fit: BoxFit.cover,
                                      width: 110,
                                      height: 110,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              SvgPicture.asset(
                                                'assets/svg/user.svg',
                                                width: 60,
                                                height: 60,
                                                colorFilter: ColorFilter.mode(
                                                  AppTheme.lightBlue,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                    )
                                    : Center(
                                      child: SvgPicture.asset(
                                        'assets/svg/user.svg',
                                        width: 60,
                                        height: 60,
                                        colorFilter: ColorFilter.mode(
                                          AppTheme.lightBlue,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                    const SizedBox(height: 10),
                    // Show car owner name directly under the profile icon
                    _ownerData != null &&
                            _ownerData!['fullName'] != null &&
                            (_ownerData!['fullName'] as String)
                                .trim()
                                .isNotEmpty
                        ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _ownerData!['fullName'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.lightBlue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (_ownerData!['organizationName'] != null &&
                                (_ownerData!['organizationName'] as String)
                                    .trim()
                                    .isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4.0,
                                  bottom: 12.0,
                                ),
                                child: Text(
                                  _ownerData!['organizationName'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.paleBlue,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                              const SizedBox(height: 12.0),
                          ],
                        )
                        : const SizedBox.shrink(),
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
                          (context) =>
                              const DocumentVerificationCarOwnerScreen(),
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
