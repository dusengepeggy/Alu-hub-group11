import 'package:flutter/material.dart';

/// Centralised theme. Matches the provided inspiration's visual language —
/// a deep navy canvas with a gold accent — as the brief instructs ("guide
/// the visual theme and color palette"). Gold is deliberately RESERVED for
/// our verification badges and primary actions so trust signals stand out
/// against the dark UI: that reuse of the inspo's own accent color for our
/// differentiator is an intentional design decision worth explaining.
class AppTheme {
  // Core palette (navy + gold, from the inspiration)
  static const Color navy = Color(0xFF0E1A2B);        // deepest background
  static const Color navySurface = Color(0xFF16243A);  // cards / surfaces
  static const Color navyElevated = Color(0xFF1E3050); // elevated surfaces
  static const Color gold = Color(0xFFF5B528);         // primary accent + badge
  static const Color goldDeep = Color(0xFFD99A1C);
  static const Color textLight = Color(0xFFF3F5F8);
  static const Color textMuted = Color(0xFF9AA8BC);
  static const Color sage = Color(0xFF6BA88F);         // secondary accent

  static ThemeData dark() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: navy,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        primary: gold,
        secondary: sage,
        surface: navySurface,
        brightness: Brightness.dark,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textLight,
        displayColor: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: navySurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0x1AFFFFFF)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: navy, // dark text on gold = high contrast
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navySurface,
        indicatorColor: gold.withValues(alpha: 0.18),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, color: textMuted),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: navyElevated,
        selectedColor: gold,
        labelStyle: const TextStyle(color: textLight),
        secondaryLabelStyle: const TextStyle(color: navy),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: navySurface,
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gold),
        ),
      ),
    );
  }
}
