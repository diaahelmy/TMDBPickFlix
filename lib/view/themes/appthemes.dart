import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Professional color palette for movies app
  static const Color _primaryColor = Color(0xFF1976D2); // Cinema blue
  static const Color _accentColor = Color(0xFFFF6B35); // Orange accent
  static const Color _darkSurface = Color(0xFF0D1117); // Deep dark
  static const Color _darkCard = Color(0xFF161B22); // Card background

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      secondary: _accentColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // Professional AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Enhanced Chip Theme for movie genres/filters
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        selectedColor: _accentColor.withValues(alpha: 0.9),
        disabledColor: colorScheme.surfaceContainerHighest,
        side: BorderSide.none,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        selectedShadowColor: _accentColor.withValues(alpha: 0.3),
      ),

      // Professional Typography
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),

      // Enhanced Button Themes
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: _accentColor.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Card Theme for movie cards
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorScheme.surface,
      ),

      // Bottom Navigation for movies app
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: _accentColor,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
      primary: _primaryColor,
      secondary: _accentColor,
      surface: _darkSurface,
      surfaceContainer: _darkCard,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkSurface,

      // Dark AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Dark Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _darkCard,
        selectedColor: _accentColor,
        disabledColor: colorScheme.surfaceContainerHighest,
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        showCheckmark: false,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        selectedShadowColor: _accentColor.withValues(alpha: 0.3),
      ),

      // Dark Typography
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),

      // Dark Button Themes
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accentColor,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: _accentColor.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkCard,
          foregroundColor: colorScheme.onSurface,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Dark Card Theme
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _darkCard,
      ),

      // Dark Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkCard,
        selectedItemColor: _accentColor,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
