import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_fonts.dart';

class AppThemes {
  // Primary brand colors inspired by KuCoin
  static const Color _primaryGreen = Color(0xFF0ECE7A);
  static const Color _primaryRed = Color(0xFFFF5A5F);
  static const Color _accentBlue = Color(0xFF1890FF);
  static const Color _warningOrange = Color(0xFFFF8700);
  static const Color _accentOrange =
      Color(0xFFF97316); // Added for ICO creator features

  // Dark theme colors
  static const Color _darkBackground = Color(0xFF0A0A0A);
  static const Color _darkSurface = Color(0xFF141414);
  static const Color _darkCard = Color(0xFF1A1A1A);
  static const Color _darkNavBar = Color(0xFF0F0F0F);
  static const Color _darkBorder = Color(0xFF2A2A2A);
  static const Color _darkInput = Color(0xFF1F1F1F);

  // Light theme colors
  static const Color _lightBackground = Color(0xFFF7F8FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightNavBar = Color(0xFFFFFFFF);
  static const Color _lightBorder = Color(0xFFE4E4E7);
  static const Color _lightInput = Color(0xFFF5F5F5);

  // Text colors
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFFB0B3B8);
  static const Color _darkTextTertiary = Color(0xFF71757A);
  static const Color _lightTextPrimary = Color(0xFF1E222D);
  static const Color _lightTextSecondary = Color(0xFF6B7280);
  static const Color _lightTextTertiary = Color(0xFF9CA3AF);

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _primaryGreen,
      scaffoldBackgroundColor: _darkBackground,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: _primaryGreen,
        primaryContainer: Color(0xFF0D4429),
        secondary: _primaryRed,
        secondaryContainer: Color(0xFF4A1A1A),
        tertiary: _accentBlue,
        tertiaryContainer: Color(0xFF1A2B4A),
        surface: _darkBackground,
        surfaceContainerHighest: _darkInput,
        error: _primaryRed,
        outline: _darkBorder,
        outlineVariant: Color(0xFF3A3E4A),
        onPrimary: Colors.white,
        onPrimaryContainer: Colors.white,
        onSecondary: Colors.white,
        onSecondaryContainer: Colors.white,
        onSurface: _darkTextPrimary,
        onSurfaceVariant: _darkTextSecondary,
        onError: Colors.white,
        shadow: Colors.black26,
      ),

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: _darkTextPrimary, size: 24),
        actionsIconTheme:
            const IconThemeData(color: _darkTextPrimary, size: 24),
        titleTextStyle: AppFonts.headlineMedium(color: _darkTextPrimary),
        toolbarTextStyle: AppFonts.bodyMedium(color: _darkTextPrimary),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: _darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _darkBorder, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),

      // Text theme with Inter font
      textTheme: AppFonts.getInterTextTheme().copyWith(
        displayLarge: AppFonts.displayLarge(color: _darkTextPrimary),
        displayMedium: AppFonts.displayMedium(color: _darkTextPrimary),
        displaySmall: AppFonts.displaySmall(color: _darkTextPrimary),
        headlineLarge: AppFonts.headlineLarge(color: _darkTextPrimary),
        headlineMedium: AppFonts.headlineMedium(color: _darkTextPrimary),
        headlineSmall: AppFonts.headlineSmall(color: _darkTextPrimary),
        titleLarge: AppFonts.titleLarge(color: _darkTextPrimary),
        titleMedium: AppFonts.titleMedium(color: _darkTextPrimary),
        titleSmall: AppFonts.titleSmall(color: _darkTextSecondary),
        bodyLarge: AppFonts.bodyLarge(color: _darkTextSecondary),
        bodyMedium: AppFonts.bodyMedium(color: _darkTextSecondary),
        bodySmall: AppFonts.bodySmall(color: _darkTextTertiary),
        labelLarge: AppFonts.labelLarge(color: _darkTextPrimary),
        labelMedium: AppFonts.labelMedium(color: _darkTextSecondary),
        labelSmall: AppFonts.labelSmall(color: _darkTextTertiary),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkTextPrimary,
          side: const BorderSide(color: _darkBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkInput,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryRed, width: 2),
        ),
        labelStyle: const TextStyle(color: _darkTextSecondary),
        hintStyle: const TextStyle(color: _darkTextTertiary),
        errorStyle: const TextStyle(color: _primaryRed),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkNavBar,
        selectedItemColor: _primaryGreen,
        unselectedItemColor: _darkTextTertiary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: _darkBorder,
        thickness: 0.5,
        space: 1,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return _darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryGreen;
          }
          return _darkBorder;
        }),
      ),

      // Slider theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: _primaryGreen,
        inactiveTrackColor: _darkBorder,
        thumbColor: _primaryGreen,
        overlayColor: Color(0x290ECE7A),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: _darkTextSecondary,
        size: 24,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
      ),
    );
  }

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _primaryGreen,
      scaffoldBackgroundColor: _lightBackground,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: _primaryGreen,
        primaryContainer: Color(0xFFE8F5F0),
        secondary: _primaryRed,
        secondaryContainer: Color(0xFFFFE8E8),
        tertiary: _accentBlue,
        tertiaryContainer: Color(0xFFE8F4FF),
        surface: _lightBackground,
        surfaceContainerHighest: _lightCard,
        error: _primaryRed,
        outline: _lightBorder,
        outlineVariant: Color(0xFFF0F0F0),
        onPrimary: Colors.white,
        onPrimaryContainer: Color(0xFF0A5D3A),
        onSecondary: Colors.white,
        onSecondaryContainer: Color(0xFF5A1F22),
        onSurface: _lightTextPrimary,
        onSurfaceVariant: _lightTextSecondary,
        onError: Colors.white,
        shadow: Colors.black12,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: _lightTextPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: _lightTextPrimary, size: 24),
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        toolbarTextStyle: TextStyle(color: _lightTextPrimary),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: _lightCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _lightBorder, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      ),

      // Text theme (similar structure to dark but with light colors)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: _lightTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: _lightTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          color: _lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          color: _lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        headlineMedium: TextStyle(
          color: _lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: _lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: _lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          color: _lightTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: _lightTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: _lightTextSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: _lightTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: _lightTextTertiary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: _lightTextPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: _lightTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: _lightTextTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Button themes (similar to dark theme)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightTextPrimary,
          side: const BorderSide(color: _lightBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightInput,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryRed, width: 2),
        ),
        labelStyle: const TextStyle(color: _lightTextSecondary),
        hintStyle: const TextStyle(color: _lightTextTertiary),
        errorStyle: const TextStyle(color: _primaryRed),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightNavBar,
        selectedItemColor: _primaryGreen,
        unselectedItemColor: _lightTextTertiary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: _lightBorder,
        thickness: 0.5,
        space: 1,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return _lightTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryGreen;
          }
          return _lightBorder;
        }),
      ),

      // Slider theme
      sliderTheme: const SliderThemeData(
        activeTrackColor: _primaryGreen,
        inactiveTrackColor: _lightBorder,
        thumbColor: _primaryGreen,
        overlayColor: Color(0x290ECE7A),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: _lightTextSecondary,
        size: 24,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
      ),
    );
  }

  // Crypto-specific colors
  static const Color priceUpColor = _primaryGreen;
  static const Color priceDownColor = _primaryRed;
  static const Color priceNeutralColor = Color(0xFF71757A);

  // Trading colors
  static const Color buyColor = _primaryGreen;
  static const Color sellColor = _primaryRed;
  static const Color warningColor = _warningOrange;
  static const Color infoColor = _accentBlue;
  static const Color orangeAccent = _accentOrange;
}

// Extension for additional theme-related properties
extension ColorSchemeExtension on ColorScheme {
  Color get success => AppThemes.priceUpColor;
  Color get warning => AppThemes.warningColor;
  Color get info => AppThemes.infoColor;
  Color get priceUp => AppThemes.priceUpColor;
  Color get priceDown => AppThemes.priceDownColor;
  Color get priceNeutral => AppThemes.priceNeutralColor;
  Color get buy => AppThemes.buyColor;
  Color get sell => AppThemes.sellColor;
  Color get orange => AppThemes.orangeAccent;
}
