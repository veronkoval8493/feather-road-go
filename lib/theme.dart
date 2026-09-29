import 'package:flutter/material.dart';

/// Canonical visual preset descriptor (one of the ten workspace presets).
class AppPreset {
  final String name;
  const AppPreset({required this.name});
}

const AppPreset kAppPreset = AppPreset(name: 'WARM_EARTHY');

/// WARM_EARTHY palette with the brief's exact accent hexes.
class AppColors {
  const AppColors._();

  static const Color deep = Color(0xFF18202A);
  static const Color deepDark = Color(0xFF0E141C);
  static const Color surface = Color(0xFFFFF3DC);
  static const Color surfaceAlt = Color(0xFFE8DDC4);
  static const Color surfaceBorder = Color(0xFFD8C9A8);
  static const Color felt = Color(0xFFF2EAD8);
  static const Color wood = Color(0xFF3A2E22);
  static const Color woodEdge = Color(0xFF8A6A46);

  static const Color gold = Color(0xFFF2C64A);
  static const Color goldDeep = Color(0xFFE8A93A);
  static const Color orange = Color(0xFFE56A45);
  static const Color cyan = Color(0xFF50B7C8);
  static const Color green = Color(0xFF8ACA5A);
  static const Color greenDeep = Color(0xFF6FAF48);

  static const Color textPrimary = Color(0xFF18202A);
  static const Color textSecondary = Color(0xFF8A7A5E);
  static const Color textOnDark = Color(0xFFFFF3DC);
  static const Color pointerIdle = Color(0xFF7D7466);

  /// Route colours, indexed by pair (max four pairs per scheme).
  static const List<Color> routes = <Color>[gold, orange, cyan, green];
}

ThemeData buildAppTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: AppColors.gold,
    brightness: Brightness.light,
  ).copyWith(
    surface: AppColors.surface,
    primary: AppColors.gold,
    secondary: AppColors.cyan,
    tertiary: AppColors.green,
    onSurface: AppColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.deep,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        letterSpacing: 3.0,
        color: AppColors.textOnDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: AppColors.textSecondary,
      ),
    ),
  );
}
