import 'package:agrishield/app/theme/agri_tokens.dart';
import 'package:flutter/material.dart';

class AgriTheme {
  static const background = Color(0xFFF4F8F1);
  static const card = Color(0xFFFFFFFF);
  static const fieldGreen = Color(0xFF34C759);
  static const deepGreen = Color(0xFF218A44);
  static const warning = Color(0xFFFF9500);
  static const critical = Color(0xFFFF3B30);
  static const text = Color(0xFF0B1014);
  static const muted = Color(0xFF697386);
  static const line = Color(0xFFE4E8E2);
  static const softGreen = Color(0xFFE4F8EA);
  static const softAmber = Color(0xFFFFF3DD);
  static const softRed = Color(0xFFFFE8E7);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: fieldGreen,
      brightness: Brightness.light,
      surface: card,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      extensions: const [AgriFieldTokens.light],
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          height: 1.1,
          fontWeight: FontWeight.w800,
          color: text,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          height: 1.15,
          fontWeight: FontWeight.w800,
          color: text,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          height: 1.2,
          fontWeight: FontWeight.w800,
          color: text,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: text,
        ),
        bodyLarge: TextStyle(fontSize: 15, height: 1.35, color: text),
        bodyMedium: TextStyle(fontSize: 13, height: 1.35, color: muted),
        labelLarge: TextStyle(
          fontSize: 13,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
