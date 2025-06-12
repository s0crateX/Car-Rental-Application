import 'package:flutter/material.dart';

/// A utility class that provides methods to show validation error snackbars.
///
/// This class contains static methods that can be used throughout the app
/// to display consistent validation error messages to the user.
class ValidationSnackbar {
  /// Shows a field validation error snackbar
  static void showFieldValidationError(BuildContext context) {
    _showGenericValidationError(
      context,
      'Please fill all fields',
    );
  }

  /// Shows a password mismatch error snackbar
  static void showPasswordMismatchError(BuildContext context) {
    _showGenericValidationError(
      context,
      'Passwords do not match',
    );
  }

  /// Shows a password strength error snackbar
  static void showPasswordStrengthError(BuildContext context) {
    _showGenericValidationError(
      context,
      'Please use a stronger password',
    );
  }

  static void _showGenericValidationError(
    BuildContext context,
    String message,
  ) {
    // Define validation colors and styles
    final List<Color> gradientColors = [Color(0xFFE65100), Color(0xFFFF9800)];
    final Color iconColor = Colors.white;
    final Color textColor = Colors.white;
    
    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: textColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withOpacity(0.9),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('DISMISS'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
