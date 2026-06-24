import 'package:flutter/material.dart';

class LumioTheme {
  static const ink = Color(0xFF14213D);
  static const surface = Color(0xFFF6F8FB);
  static const panel = Color(0xFFFFFFFF);
  static const teal = Color(0xFF13A89E);
  static const blue = Color(0xFF3468D9);
  static const amber = Color(0xFFF2A541);
  static const coral = Color(0xFFE76F51);
  static const mint = Color(0xFFE6F6F3);
  static const line = Color(0xFFE2E8F0);
  static const muted = Color(0xFF667085);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: teal,
      brightness: Brightness.light,
      primary: teal,
      secondary: blue,
      tertiary: amber,
      surface: panel,
      error: coral,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      fontFamily: 'Segoe UI',
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
        fontFamily: 'Segoe UI',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: teal, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: mint,
        side: const BorderSide(color: Color(0xFFD7EFEB)),
        labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(color: line, thickness: 1),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: teal,
        thumbColor: teal,
        inactiveTrackColor: line,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: teal,
        linearTrackColor: line,
      ),
    );
  }
}
