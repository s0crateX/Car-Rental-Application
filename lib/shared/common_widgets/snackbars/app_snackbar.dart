import 'package:flutter/material.dart';

/// A utility class that provides methods to show different types of snackbars.
///
/// This class serves as a central point for displaying various types of snackbars
/// throughout the app, ensuring a consistent UI experience.
class AppSnackbar {
  /// Shows a standard snackbar with the given [message] and [type].
  ///
  /// [context] is required to show the snackbar.
  /// [message] is the message to be displayed.
  /// [type] determines the style and icon of the snackbar.
  /// [duration] is optional and defaults based on the type.
  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    Duration? duration,
  }) {
    // Define properties based on type
    IconData icon;
    List<Color> gradientColors;
    Color iconColor;
    Color textColor;
    Duration defaultDuration;
    Color actionTextColor;

    switch (type) {
      case SnackbarType.success:
        icon = Icons.check_circle_rounded;
        gradientColors = [Color(0xFF1E8E3E), Color(0xFF34A853)];
        iconColor = Colors.white;
        textColor = Colors.white;
        actionTextColor = Colors.white.withOpacity(0.9);
        defaultDuration = const Duration(seconds: 3);
        break;
      case SnackbarType.error:
        icon = Icons.error_rounded;
        gradientColors = [Color(0xFFD93025), Color(0xFFEA4335)];
        iconColor = Colors.white;
        textColor = Colors.white;
        actionTextColor = Colors.white.withOpacity(0.9);
        defaultDuration = const Duration(seconds: 4);
        break;
      case SnackbarType.info:
        icon = Icons.info_rounded;
        gradientColors = [Color(0xFF1A73E8), Color(0xFF4285F4)];
        iconColor = Colors.white;
        textColor = Colors.white;
        actionTextColor = Colors.white.withOpacity(0.9);
        defaultDuration = const Duration(seconds: 3);
        break;
      case SnackbarType.warning:
        icon = Icons.warning_rounded;
        gradientColors = [Color(0xFFF9AB00), Color(0xFFFBBC04)];
        iconColor = Colors.white;
        textColor = Colors.white;
        actionTextColor = Colors.white.withOpacity(0.9);
        defaultDuration = const Duration(seconds: 4);
        break;
    }

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
                icon,
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
                foregroundColor: actionTextColor,
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
      duration: duration ?? defaultDuration,
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );

    // Ensure any existing snackbar is hidden before showing the new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Shows a success snackbar with the given [message].
  static void success({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.success,
      duration: duration,
    );
  }

  /// Shows an error snackbar with the given [message].
  static void error({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.error,
      duration: duration,
    );
  }

  /// Shows an info snackbar with the given [message].
  static void info({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.info,
      duration: duration,
    );
  }

  /// Shows a warning snackbar with the given [message].
  static void warning({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
    );
  }

  // Common predefined messages

  /// Shows a network error snackbar.
  static void networkError({
    required BuildContext context,
    String? customMessage,
  }) {
    error(
      context: context,
      message: customMessage ?? 'Network error. Please check your connection.',
    );
  }

  /// Shows a login success snackbar.
  static void loginSuccess({
    required BuildContext context,
    String? customMessage,
  }) {
    success(
      context: context,
      message: customMessage ?? 'Login successful!',
    );
  }

  /// Shows a registration success snackbar.
  static void registrationSuccess({
    required BuildContext context,
    String? customMessage,
  }) {
    success(
      context: context,
      message: customMessage ?? 'Registration successful!',
    );
  }

  /// Shows a validation error snackbar.
  static void validationError({
    required BuildContext context,
    required String message,
  }) {
    error(
      context: context,
      message: message,
    );
  }

  /// Shows a permission warning snackbar.
  static void permissionWarning({
    required BuildContext context,
    String? customMessage,
  }) {
    warning(
      context: context,
      message: customMessage ?? 'You do not have permission to perform this action.',
    );
  }

  /// Shows a feature info snackbar.
  static void featureInfo({
    required BuildContext context,
    String? customMessage,
  }) {
    info(
      context: context,
      message: customMessage ?? 'This feature will be available soon!',
    );
  }
}

/// Enum defining the different types of snackbars available.
enum SnackbarType {
  success,
  error,
  info,
  warning,
}
