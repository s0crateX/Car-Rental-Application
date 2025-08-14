import 'package:flutter/material.dart';

class AppTheme {
  // Colors from the provided palette
  static const Color darkNavy = Color(0xFF021024);
  static const Color navy = Color(0xFF052659);
  static const Color mediumBlue = Color(0xFF5483B3);
  static const Color lightBlue = Color(0xFF7DA0C4);
  static const Color paleBlue = Color(0xFFC1E8FF);
  static const Color green = Colors.green;
  static const Color red = Colors.red;
  static const Color orange = Colors.orange;
  static const Color blue = Colors.blue;

  // Additional standard colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color surface = Colors.pinkAccent;

  // Create theme data for the app
  static ThemeData get theme {
    return ThemeData(
      primaryColor: mediumBlue,
      scaffoldBackgroundColor: darkNavy,
      fontFamily: 'General Sans',
      colorScheme: ColorScheme.dark(
        primary: mediumBlue,
        secondary: lightBlue,
        surface: navy,
        error: Colors.redAccent,
      ),
      textTheme: const TextTheme(
        // Large display text (32px)
        displayLarge: TextStyle(
          color: white, 
          fontWeight: FontWeight.w300,
          fontSize: 32,
          fontFamily: 'General Sans',
          letterSpacing: -0.5,
        ),
        // Medium display text (28px)
        displayMedium: TextStyle(
          color: white, 
          fontWeight: FontWeight.w300,
          fontSize: 28,
          fontFamily: 'General Sans',
          letterSpacing: -0.25,
        ),
        // Small display text (24px)
        displaySmall: TextStyle(
          color: white, 
          fontWeight: FontWeight.w400,
          fontSize: 24,
          fontFamily: 'General Sans',
          letterSpacing: 0,
        ),
        // Medium headline (22px) - for important headers
        headlineMedium: TextStyle(
          color: white, 
          fontWeight: FontWeight.w500,
          fontSize: 22,
          fontFamily: 'General Sans',
          letterSpacing: 0,
        ),
        // Small headline (20px) - for section headers
        headlineSmall: TextStyle(
          color: white, 
          fontWeight: FontWeight.w500,
          fontSize: 20,
          fontFamily: 'General Sans',
          letterSpacing: 0.15,
        ),
        // Large title (18px) - for card titles, dialog titles
        titleLarge: TextStyle(
          color: white, 
          fontWeight: FontWeight.w500,
          fontSize: 18,
          fontFamily: 'General Sans',
          letterSpacing: 0.15,
        ),
        // Medium title (16px) - for list item titles
        titleMedium: TextStyle(
          color: white, 
          fontWeight: FontWeight.w400,
          fontSize: 16,
          fontFamily: 'General Sans',
          letterSpacing: 0.15,
        ),
        // Small title (14px) - for smaller titles
        titleSmall: TextStyle(
          color: white, 
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: 'General Sans',
          letterSpacing: 0.1,
        ),
        // Large body text (16px) - for important content
        bodyLarge: TextStyle(
          color: white,
          fontWeight: FontWeight.w300,
          fontSize: 16,
          fontFamily: 'General Sans',
          letterSpacing: 0.5,
        ),
        // Medium body text (14px) - for regular content
        bodyMedium: TextStyle(
          color: paleBlue,
          fontWeight: FontWeight.w300,
          fontSize: 14,
          fontFamily: 'General Sans',
          letterSpacing: 0.25,
        ),
        // Small body text (12px) - for captions and small text
        bodySmall: TextStyle(
          color: paleBlue,
          fontWeight: FontWeight.w300,
          fontSize: 12,
          fontFamily: 'General Sans',
          letterSpacing: 0.4,
        ),
        // Label large (14px) - for button text and form labels
        labelLarge: TextStyle(
          color: white,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: 'General Sans',
          letterSpacing: 1.25,
        ),
        // Label medium (12px) - for smaller labels
        labelMedium: TextStyle(
          color: white,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          fontFamily: 'General Sans',
          letterSpacing: 1.5,
        ),
        // Label small (11px) - for very small labels and captions
        labelSmall: TextStyle(
          color: lightBlue,
          fontWeight: FontWeight.w300,
          fontSize: 11,
          fontFamily: 'General Sans',
          letterSpacing: 1.5,
        ),
      ),
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: navy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: mediumBlue),
        ),
        hintStyle: const TextStyle(
          color: lightBlue,
          fontWeight: FontWeight.w300,
          fontSize: 14,
          fontFamily: 'General Sans',
        ),
        labelStyle: const TextStyle(
          color: lightBlue,
          fontWeight: FontWeight.w300,
          fontSize: 14,
          fontFamily: 'General Sans',
        ),
      ),
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(lightBlue),
          foregroundColor: WidgetStateProperty.all(navy),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 15),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              fontFamily: 'General Sans',
              letterSpacing: 1.25,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(lightBlue),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              fontFamily: 'General Sans',
              letterSpacing: 1.25,
            ),
          ),
        ),
      ),
      // AppBar theme for header titles
      appBarTheme: const AppBarTheme(
        backgroundColor: darkNavy,
        foregroundColor: white,
        titleTextStyle: TextStyle(
          color: white,
          fontWeight: FontWeight.w500,
          fontSize: 20,
          fontFamily: 'General Sans',
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}