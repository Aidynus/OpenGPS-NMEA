import 'package:flutter/material.dart';

/// Brand gradients (deep navy → electric blue, like the app icon).
class AppGradients {
  AppGradients._();

  static const appBar = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF0A1B4D), Color(0xFF1F6BFF), Color(0xFF29B6F6)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
  );
}

class AppTheme {
  AppTheme._();

  static const _primaryColor = Color(0xFF2F80FF); // electric blue
  static const _secondaryColor = Color(0xFF00B8D9); // cyan
  static const _tertiaryColor = Color(0xFF7C4DFF); // violet accent
  static const _errorColor = Color(0xFFE53935);

  static const _lightBg = Color(0xFFEAF2FF);
  static const _darkBg = Color(0xFF070D1C);
  static const _darkCard = Color(0xFF111B33);

  static const _gradientAppBar = AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Color(0xFF1F6BFF),
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
        fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
  );

  static final _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => states.contains(WidgetState.selected)
            ? Colors.white
            : null),
    trackColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => states.contains(WidgetState.selected)
            ? const Color(0xFF22C55E)
            : null),
  );

  // ── Light (colourful) ───────────────────────────────────────────────────

  static ThemeData lowContrast = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      error: _errorColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: _lightBg,
    appBarTheme: _gradientAppBar,
    cardTheme: CardThemeData(
      elevation: 3,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: const Color(0x552F80FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x222F80FF)),
      ),
    ),
    switchTheme: _switchTheme,
    dividerTheme: const DividerThemeData(color: Color(0x222F80FF)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // ── Light (high contrast) ───────────────────────────────────────────────

  static ThemeData highContrast = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D47A1),
      secondary: const Color(0xFF00695C),
      error: const Color(0xFFB71C1C),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF0D47A1),
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black26),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(
          fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w400),
      headlineSmall: TextStyle(
          fontSize: 20, color: Colors.black, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.black54, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.black54, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: TextStyle(color: Colors.black87),
      floatingLabelStyle: TextStyle(color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );

  // ── Dark (colourful night) ──────────────────────────────────────────────

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      error: const Color(0xFFFF6B6B),
      brightness: Brightness.dark,
    ).copyWith(
      surface: _darkBg,
      surfaceContainerHighest: const Color(0xFF1B2A4A),
      primary: const Color(0xFF5B9DFF),
    ),
    scaffoldBackgroundColor: _darkBg,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xFF0A1B4D),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: _darkCard,
      surfaceTintColor: _darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0x552F80FF)),
      ),
    ),
    switchTheme: _switchTheme,
    dividerTheme: const DividerThemeData(color: Color(0x332F80FF)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5B9DFF), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF2F80FF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // ── Dark high contrast ──────────────────────────────────────────────────

  static ThemeData darkHighContrast = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF90CAF9),
      secondary: const Color(0xFF80CBC4),
      error: const Color(0xFFEF9A9A),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
          fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(
          fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w400),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.white54, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.white54, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: TextStyle(color: Colors.white70),
      floatingLabelStyle: TextStyle(color: Colors.white),
    ),
  );
}
