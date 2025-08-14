import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/utils/helpers/verification_helper.dart';
import 'package:car_rental_app/presentation/screens/Car Owner/profile/document_verification_Carowner.dart';

class AddCarButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddCarButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final userData = authService.userData;
        final isVerified = VerificationHelper.isCarOwnerVerified(userData);
        final statusMessage = VerificationHelper.getVerificationStatusMessage(userData);
        
        return Center(
          child: GestureDetector(
            onTap: isVerified ? onPressed : () => _showVerificationDialog(context, statusMessage),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isVerified 
                    ? [AppTheme.navy, AppTheme.navy.withOpacity(0.8)]
                    : [Colors.grey.shade600, Colors.grey.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isVerified 
                    ? AppTheme.mediumBlue.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: isVerified ? [
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
                ] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                        colors: isVerified ? [
                          AppTheme.mediumBlue.withOpacity(0.3),
                          AppTheme.lightBlue.withOpacity(0.2),
                        ] : [
                          Colors.grey.withOpacity(0.3),
                          Colors.grey.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      isVerified ? 'assets/svg/plus.svg' : 'assets/svg/lock.svg',
                      width: 24,
                      height: 24,
                      color: isVerified ? AppTheme.lightBlue : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isVerified ? 'Add New Car' : 'Verification Required',
                    style: TextStyle(
                      color: isVerified ? AppTheme.lightBlue : Colors.grey.shade400,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'General Sans',
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (!isVerified) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Complete document verification',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'General Sans',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showVerificationDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.verified_user,
                color: AppTheme.lightBlue,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Verification Required',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: AppTheme.paleBlue,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.lightBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to document verification screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DocumentVerificationCarOwnerScreen(),
                  ),
                );
              },
              child: const Text(
                'Verify Now',
                style: TextStyle(
                  color: AppTheme.lightBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
