import 'package:flutter/material.dart';


class AppTheme {
  static const Color navy = Color(0xFF0E1A2B);
  static const Color navySurface = Color(0xFF16243A);
  static const Color navyElevated = Color(0xFF1E3050);
 
  static const Color gold = Color(0xFFF5B528);
  static const Color goldDeep = Color(0xFFD99A1C);

  static const Color textLight = Color(0xFFF3F5F8);
  static const Color textMuted = Color(0xFF9AA8BC);

  static const Color sage = Color(0xFF6BA88F);

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    return base.copyWith(
      scaffoldBackgroundColor: navy,

      colorScheme: const ColorScheme.dark(
        primary: gold,
        secondary: sage,
        surface: navySurface,
        onPrimary: navy,
        onSurface: textLight,
      ),

      textTheme: base.textTheme.apply(
        bodyColor: textLight,
        displayColor: textLight,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: textLight,
        centerTitle: false,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: navySurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: Color(0x1AFFFFFF),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: navy,
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navySurface,
        indicatorColor: gold.withValues(alpha: 0.18),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontSize: 11,
            color: textMuted,
          ),
        ),
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: navyElevated,
        selectedColor: gold,
        labelStyle: const TextStyle(
          color: textLight,
        ),
        secondaryLabelStyle: const TextStyle(
          color: navy,
        ),
        side: BorderSide.none,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: navySurface,

        hintStyle: const TextStyle(
          color: textMuted,
        ),

        labelStyle: const TextStyle(
          color: textMuted,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0x1AFFFFFF),
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0x1AFFFFFF),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: gold,
            width: 2,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0x1AFFFFFF),
      ),

      iconTheme: const IconThemeData(
        color: textLight,
      ),
    );
  }
}