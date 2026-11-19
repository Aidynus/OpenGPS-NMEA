import 'package:flutter/material.dart';

/// Palette taken from the Jetour head-unit application ("new design"):
/// deep blue-black background, navy panels with a cyan glow, blue accent.
class AppColors {
  AppColors._();

  static const bg = Color(0xFF05080F);
  static const surface = Color(0xFF0C1626);
  static const surfaceAlt = Color(0xFF112038);
  static const input = Color(0xFF08101D);
  static const stroke = Color(0xFF1F3B66);
  static const accent = Color(0xFF2F8CFF);
  static const accentPressed = Color(0xFF1B5FBF);
  static const textPrimary = Color(0xFFF4F8FF);
  static const textSecondary = Color(0xFFC3D2E6);
  static const textMuted = Color(0xFF7F93AE);
  static const warning = Color(0xFFF0B45B);
  static const danger = Color(0xFFE0556B);
  static const success = Color(0xFF4FD1A1);
  static const glow = Color(0xFF3CC8FF);
  static const panelTop = Color(0xFF12203A);
  static const panelBottom = Color(0xFF080F1D);
}

class AppGradients {
  AppGradients._();

  /// Behind the app bars: slightly lighter navy fading into the background.
  static const appBar = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF16305A), AppColors.bg],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    border: Border(bottom: BorderSide(color: AppColors.stroke)),
  );

  static const panel = LinearGradient(
    colors: [AppColors.panelTop, AppColors.panelBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Rounded gradient panel with an optional glowing outline.
class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// When set, the panel gets a glowing outline in this colour.
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final glowColor = accent;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: AppGradients.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: glowColor == null ? AppColors.stroke : glowColor.withAlpha(190),
        ),
        boxShadow: glowColor == null
            ? const <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: glowColor.withAlpha(60),
                  blurRadius: 18,
                ),
              ],
      ),
      child: child,
    );
  }
}

class AppTheme {
  AppTheme._();

  /// The application is dark only, like the head-unit application.
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.glow,
      tertiary: AppColors.success,
      error: AppColors.danger,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.stroke,
      surfaceContainerHighest: AppColors.surfaceAlt,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    canvasColor: AppColors.surfaceAlt,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.stroke),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.stroke, space: 1),
    expansionTileTheme: const ExpansionTileThemeData(
      iconColor: AppColors.glow,
      collapsedIconColor: AppColors.textMuted,
      textColor: AppColors.textPrimary,
      collapsedTextColor: AppColors.textPrimary,
      shape: Border(),
      collapsedShape: Border(),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (states) =>
            states.contains(WidgetState.selected) ? Colors.white : null,
      ),
      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (states) =>
            states.contains(WidgetState.selected) ? AppColors.accent : null,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: AppColors.input,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.stroke),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.stroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.glow),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceAlt,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
