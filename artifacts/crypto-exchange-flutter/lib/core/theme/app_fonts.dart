import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global font system for crypto trading app
/// Uses Inter font family to match KuCoin's professional typography
class AppFonts {
  // Private constructor to prevent instantiation
  AppFonts._();

  /// Primary font family for the app (Inter)
  static const String _primaryFontFamily = 'Inter';

  /// Get Inter font TextTheme for any base theme
  static TextTheme getInterTextTheme([TextTheme? baseTheme]) {
    return GoogleFonts.interTextTheme(baseTheme);
  }

  /// Create TextStyle with Inter font and custom properties
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? lineHeight,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: lineHeight,
      decoration: decoration,
      fontStyle: fontStyle,
    );
  }

  // MARK: - Predefined Text Styles

  /// Display styles for large headings
  static TextStyle displayLarge({Color? color}) => inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle displayMedium({Color? color}) => inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: color,
      );

  static TextStyle displaySmall({Color? color}) => inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      );

  /// Headline styles for section headers
  static TextStyle headlineLarge({Color? color}) => inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: color,
      );

  static TextStyle headlineMedium({Color? color}) => inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle headlineSmall({Color? color}) => inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// Title styles for cards and components
  static TextStyle titleLarge({Color? color}) => inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle titleMedium({Color? color}) => inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle titleSmall({Color? color}) => inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );

  /// Body text styles for content
  static TextStyle bodyLarge({Color? color}) => inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodySmall({Color? color}) => inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      );

  /// Label styles for buttons and small text
  static TextStyle labelLarge({Color? color}) => inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelMedium({Color? color}) => inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelSmall({Color? color}) => inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      );

  // MARK: - Crypto-Specific Styles

  /// Price display styles (monospace-like for better alignment)
  static TextStyle priceDisplay({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) =>
      inter(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w600,
        letterSpacing: 0.2, // Slightly more spacing for numbers
        color: color,
      );

  /// Large price display for main trading view
  static TextStyle priceLarge({Color? color}) => priceDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color,
      );

  /// Medium price display for cards
  static TextStyle priceMedium({Color? color}) => priceDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// Small price display for lists
  static TextStyle priceSmall({Color? color}) => priceDisplay(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
      );

  /// Extra small price for dense data
  static TextStyle priceXSmall({Color? color}) => priceDisplay(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );

  /// Percentage change display
  static TextStyle percentageChange({
    double? fontSize,
    Color? color,
  }) =>
      inter(
        fontSize: fontSize ?? 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      );

  /// Crypto symbol display (e.g., BTC, ETH)
  static TextStyle cryptoSymbol({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) =>
      inter(
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.w600,
        letterSpacing: 0.5, // More spacing for crypto symbols
        color: color,
      );

  /// Trading form labels
  static TextStyle formLabel({Color? color}) => inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: color,
      );

  /// Button text styles
  static TextStyle buttonText({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) =>
      inter(
        fontSize: fontSize ?? 16,
        fontWeight: fontWeight ?? FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );

  /// Tab bar text
  static TextStyle tabText({
    bool isActive = false,
    Color? color,
  }) =>
      inter(
        fontSize: 14,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      );

  /// Caption text for small information
  static TextStyle caption({Color? color}) => inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: color,
      );

  // MARK: - Special Typography

  /// Monospace-style for exact numeric data (using Inter with specific spacing)
  static TextStyle monospace({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) =>
      inter(
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.w500,
        letterSpacing: 1.0, // Much wider spacing for monospace effect
        color: color,
      );

  /// Error text style
  static TextStyle error({
    double? fontSize,
    FontWeight? fontWeight,
  }) =>
      inter(
        fontSize: fontSize ?? 12,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: const Color(0xFFFF5A5F), // Error red
      );

  /// Success text style
  static TextStyle success({
    double? fontSize,
    FontWeight? fontWeight,
  }) =>
      inter(
        fontSize: fontSize ?? 12,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: const Color(0xFF0ECE7A), // Success green
      );

  /// Warning text style
  static TextStyle warning({
    double? fontSize,
    FontWeight? fontWeight,
  }) =>
      inter(
        fontSize: fontSize ?? 12,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: const Color(0xFFF39C12), // Warning orange
      );

  // MARK: - Responsive Font Sizes

  /// Get responsive font size based on screen width
  static double getResponsiveFontSize(
    BuildContext context, {
    required double baseFontSize,
    double maxScale = 1.3,
    double minScale = 0.8,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Base calculation on 390px width (iPhone 14 Pro)
    final scale = (screenWidth / 390).clamp(minScale, maxScale);

    return baseFontSize * scale;
  }

  /// Create responsive text style
  static TextStyle responsive(
    BuildContext context, {
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double maxScale = 1.3,
    double minScale = 0.8,
  }) {
    final responsiveFontSize = getResponsiveFontSize(
      context,
      baseFontSize: baseFontSize,
      maxScale: maxScale,
      minScale: minScale,
    );

    return inter(
      fontSize: responsiveFontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }
}
