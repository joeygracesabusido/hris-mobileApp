// src/ui/widgets/app_theme.dart
import 'package:flutter/material.dart';

/// Centralised theme constants for the HRIS mobile app.
///
/// The colour palette follows a modern dark‑mode‑first approach with
/// complementary accent colours. Adjust the values here to re‑skin the app.
class AppTheme {
  // Primary accent (electric teal)
  static const Color primary = Color(0xFF00D1B2);

  // Background for the root Scaffold – dark slate
  static const Color background = Color(0xFF1E1E2E);

  // Card surface – slightly lighter than background for depth
  static const Color cardBackground = Color(0xFF2A2A3A);

  // Text colours
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0C0);

  // Gradient for headers / hero sections
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF00D1B2), Color(0xFF7ED957)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Common shadow for elevation effects
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black45,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // Configure the overall ThemeData (used in main.dart)
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: primary, foregroundColor: Colors.white),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(backgroundColor: primary, foregroundColor: Colors.white),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
    ),
    cardColor: cardBackground,
  );
}
