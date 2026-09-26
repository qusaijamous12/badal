import 'package:flutter/material.dart';

class BadalColors {
  static const forest = Color(0xFF153D35);
  static const pine = Color(0xFF245B4A);
  static const mint = Color(0xFFE5F0E7);
  static const cream = Color(0xFFFAF9F4);
  static const ink = Color(0xFF173B34);
  static const muted = Color(0xFF71837A);
  static const orange = Color(0xFFF2B778);
  static const line = Color(0xFFE1E8E0);
}

class BadalTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: BadalColors.forest,
      brightness: Brightness.light,
      surface: BadalColors.cream,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BadalColors.cream,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          height: 1.35,
          color: BadalColors.ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          height: 1.35,
          color: BadalColors.ink,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w700,
          color: BadalColors.ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.65,
          color: BadalColors.ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.55,
          color: BadalColors.muted,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: BadalColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: BadalColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: BadalColors.pine, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BadalColors.forest,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BadalColors.pine,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
