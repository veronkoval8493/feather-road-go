
import 'package:flutter/material.dart';

/// Canonical visual preset for this app. The key is fixed; only accent hexes
/// are overridden with the ticket palette.
class AppPreset {
  const AppPreset({required this.name});

  final String name;
}

const AppPreset kPreset = AppPreset(name: 'WARM_EARTHY');

/// Ticket palette mapped onto the WARM_EARTHY slots.
class AppColors {
  const AppColors._();

  static const Color ink = Color(0xFF18202A);
  static const Color inkSoft = Color(0xFF2A3442);
  static const Color surface = Color(0xFFFFF3DC);
  static const Color surfaceEdge = Color(0xFFE8DCC0);
  static const Color gold = Color(0xFFF2C64A);
  static const Color goldDeep = Color(0xFFE8A93C);
  static const Color goldEdge = Color(0xFFB07C22);
  static const Color goldText = Color(0xFF8A6D1F);
  static const Color terracotta = Color(0xFFE56A45);
  static const Color teal = Color(0xFF50B7C8);
  static const Color sage = Color(0xFF8ACA5A);
  static const Color sageDeep = Color(0xFF6FAE45);
  static const Color sageEdge = Color(0xFF4F7E30);
  static const Color woodLight = Color(0xFF9A6B3C);
  static const Color woodDark = Color(0xFF6E4A28);
  static const Color woodEdge = Color(0xFF4A3018);
  static const Color plate = Color(0xFFC9A878);
  static const Color plateEdge = Color(0xFF8A6A3E);
  static const Color felt = Color(0xFF2E4A3A);
  static const Color feltDark = Color(0xFF243A2C);
  static const Color brassLight = Color(0xFFF0D08A);
  static const Color brassDark = Color(0xFFA8822E);
  static const Color textSecondary = Color(0xFF6B5E46);
  static const Color slate = Color(0xFF3A4350);

  /// gold / teal / sage — one per grain route.
  static const List<Color> routes = <Color>[gold, teal, sage];
}

/// Tabular figures so live counters do not jitter as values change.
const List<FontFeature> kTabular = <FontFeature>[FontFeature.tabularFigures()];

ThemeData buildAppTheme() {
  const ColorScheme scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.gold,
    onPrimary: AppColors.ink,
    secondary: AppColors.sage,
    onSecondary: AppColors.ink,
    tertiary: AppColors.teal,
    onTertiary: AppColors.ink,
    error: AppColors.terracotta,
    onError: AppColors.surface,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
  );

  const TextTheme text = TextTheme(
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w900,
      letterSpacing: 3.2,
      color: AppColors.surface,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.2,
      color: AppColors.ink,
    ),
    titleMedium: TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w900,
      letterSpacing: 2.2,
      color: AppColors.ink,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: AppColors.ink,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: AppColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.4,
      color: AppColors.textSecondary,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.ink,
    textTheme: text,
    splashFactory: InkRipple.splashFactory,
  );
}
