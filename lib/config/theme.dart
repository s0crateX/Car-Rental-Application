import 'package:flutter/material.dart';

class AppTheme {
  // Colors from the provided palette
  static const Color darkNavy = Color(0xFF021024);
  static const Color navy = Color(0xFF052659);
  static const Color mediumBlue = Color(0xFF5483B3);
  static const Color lightBlue = Color(0xFF7DA0C4);
  static const Color paleBlue = Color(0xFFC1E8FF);
  static const Color green = Colors.green;

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
        displayLarge: TextStyle(color: white, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: white, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: white, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: white, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: white, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: white),
        bodyMedium: TextStyle(color: paleBlue),
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
        hintStyle: const TextStyle(color: lightBlue),
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
              fontWeight: FontWeight.bold,
              fontFamily: 'General Sans',
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(lightBlue),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontWeight: FontWeight.normal,
              fontFamily: 'General Sans',
            ),
          ),
        ),
      ),
    );
  }
}
