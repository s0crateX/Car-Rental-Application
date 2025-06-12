import 'package:flutter/material.dart';

/// A utility class that provides methods to show informational snackbars.
///
/// This class contains static methods that can be used throughout the app
/// to display consistent informational messages to the user.
class InfoSnackbar {
  /// Shows a standard info snackbar with the given [message].
  ///
  /// [context] is required to show the snackbar.
  /// [message] is the info message to be displayed.
  /// [duration] is optional and defaults to 3 seconds.
  static void show({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    // Define info colors and styles
    final List<Color> gradientColors = [Color(0xFF1A73E8), Color(0xFF4285F4)];
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
                Icons.info_rounded,
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
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );

    // Ensure any existing snackbar is hidden before showing the new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Shows a feature info snackbar with a predefined message.
  ///
  /// [context] is required to show the snackbar.
  /// [customMessage] is optional and can be used to override the default message.
  static void showFeatureInfo({
    required BuildContext context,
    String? customMessage,
  }) {
    show(
      context: context,
      message: customMessage ?? 'This feature will be available soon!',
    );
  }

  /// Shows a loading info snackbar with a predefined message.
  ///
  /// [context] is required to show the snackbar.
  /// [customMessage] is optional and can be used to override the default message.
  static void showLoadingInfo({
    required BuildContext context,
    String? customMessage,
  }) {
    show(
      context: context,
      message: customMessage ?? 'Loading data, please wait...',
    );
  }

  /// Shows a tip info snackbar with a predefined message.
  ///
  /// [context] is required to show the snackbar.
  /// [tip] is the tip message to be displayed.
  static void showTip({
    required BuildContext context,
    required String tip,
  }) {
    show(
      context: context,
      message: 'Tip: $tip',
    );
  }

  /// Shows a notification info snackbar with a predefined message.
  ///
  /// [context] is required to show the snackbar.
  /// [notification] is the notification message to be displayed.
  static void showNotification({
    required BuildContext context,
    required String notification,
  }) {
    show(
      context: context,
      message: notification,
    );
  }
}
