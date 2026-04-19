import 'package:flutter/material.dart';
import 'app_fonts.dart';
import 'app_themes.dart';

/// Global theme extensions that are automatically available
/// in all widgets without needing imports.
///
/// These extensions are added directly to BuildContext
/// and are available throughout the app.
extension GlobalThemeExtensions on BuildContext {
  /// Access the current theme
  ThemeData get theme => Theme.of(this);

  /// Access the current color scheme
  ColorScheme get colors => theme.colorScheme;

  /// Access text theme
  TextTheme get textTheme => theme.textTheme;

  /// Check if current theme is dark
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Check if current theme is light
  bool get isLightMode => theme.brightness == Brightness.light;

  // MARK: - Text Colors

  /// Primary text color (highest emphasis)
  Color get textPrimary => colors.onSurface;

  /// Secondary text color (medium emphasis)
  Color get textSecondary => colors.onSurface.withValues(alpha: 0.7);

  /// Tertiary text color (low emphasis)
  Color get textTertiary => colors.onSurface.withValues(alpha: 0.5);

  // MARK: - Background Colors

  /// Main background color
  Color get background => colors.surface;

  /// Main card background color
  Color get cardBackground => colors.surface;

  /// Input field background color
  Color get inputBackground =>
      isDarkMode ? const Color(0xFF1F1F1F) : const Color(0xFFF8F9FA);

  /// Border color for cards, inputs, etc.
  Color get borderColor => colors.outline;

  // MARK: - Crypto-specific Colors

  /// Price up/buy color (green)
  Color get priceUpColor => const Color(0xFF0ECE7A);

  /// Price down/sell color (red)
  Color get priceDownColor => const Color(0xFFFF5A5F);

  /// Buy action color (same as price up)
  Color get buyColor => priceUpColor;

  /// Sell action color (same as price down)
  Color get sellColor => priceDownColor;

  /// Orange accent color for features like ICO creator
  Color get orangeAccent => const Color(0xFFF97316);

  // MARK: - Gradients

  /// Price up gradient for containers
  LinearGradient get priceUpGradient => LinearGradient(
        colors: [
          priceUpColor.withValues(alpha: 0.1),
          priceUpColor.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Price down gradient for containers
  LinearGradient get priceDownGradient => LinearGradient(
        colors: [
          priceDownColor.withValues(alpha: 0.1),
          priceDownColor.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // MARK: - Responsive Design

  /// Screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Safe area top padding
  double get safeAreaTop => MediaQuery.of(this).padding.top;

  /// Safe area bottom padding
  double get safeAreaBottom => MediaQuery.of(this).padding.bottom;

  /// Check if screen is small (width < 600)
  bool get isSmallScreen => screenWidth < 600;

  /// Check if screen is medium (600 <= width < 1024)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1024;

  /// Check if screen is large (width >= 1024)
  bool get isLargeScreen => screenWidth >= 1024;

  // MARK: - Common Paddings

  /// Standard horizontal padding
  EdgeInsets get horizontalPadding =>
      const EdgeInsets.symmetric(horizontal: 24);

  /// Standard card padding
  EdgeInsets get cardPadding => const EdgeInsets.all(16);

  /// Small padding
  EdgeInsets get smallPadding => const EdgeInsets.all(8);

  /// Large padding
  EdgeInsets get largePadding => const EdgeInsets.all(32);

  // MARK: - Font Utilities (Global Access to AppFonts)

  /// Create Inter font style with context-aware colors
  TextStyle interStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? lineHeight,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) =>
      AppFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? textPrimary,
        letterSpacing: letterSpacing,
        lineHeight: lineHeight,
        decoration: decoration,
        fontStyle: fontStyle,
      );

  /// Quick access to common font styles
  TextStyle get h1 => AppFonts.displayLarge(color: textPrimary);
  TextStyle get h2 => AppFonts.displayMedium(color: textPrimary);
  TextStyle get h3 => AppFonts.displaySmall(color: textPrimary);
  TextStyle get h4 => AppFonts.headlineLarge(color: textPrimary);
  TextStyle get h5 => AppFonts.headlineMedium(color: textPrimary);
  TextStyle get h6 => AppFonts.headlineSmall(color: textPrimary);

  TextStyle get bodyL => AppFonts.bodyLarge(color: textSecondary);
  TextStyle get bodyM => AppFonts.bodyMedium(color: textSecondary);
  TextStyle get bodyS => AppFonts.bodySmall(color: textTertiary);
  TextStyle get bodyXS =>
      AppFonts.bodySmall(color: textTertiary).copyWith(fontSize: 10);

  TextStyle get labelL => AppFonts.labelLarge(color: textPrimary);
  TextStyle get labelM => AppFonts.labelMedium(color: textSecondary);
  TextStyle get labelS => AppFonts.labelSmall(color: textTertiary);

  /// Crypto-specific font styles
  TextStyle priceLarge({Color? color}) =>
      AppFonts.priceLarge(color: color ?? textPrimary);
  TextStyle priceMedium({Color? color}) =>
      AppFonts.priceMedium(color: color ?? textPrimary);
  TextStyle priceSmall({Color? color}) =>
      AppFonts.priceSmall(color: color ?? textPrimary);

  TextStyle cryptoSymbol({Color? color}) =>
      AppFonts.cryptoSymbol(color: color ?? textPrimary);
  TextStyle percentageChange({Color? color}) =>
      AppFonts.percentageChange(color: color ?? textSecondary);

  /// Button text style
  TextStyle buttonText({Color? color}) => AppFonts.buttonText(color: color);

  /// Form input label style
  TextStyle formLabel({Color? color}) =>
      AppFonts.formLabel(color: color ?? textSecondary);

  /// Responsive font style
  TextStyle responsiveText({
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double maxScale = 1.3,
    double minScale = 0.8,
  }) =>
      AppFonts.responsive(
        this,
        baseFontSize: baseFontSize,
        fontWeight: fontWeight,
        color: color ?? textPrimary,
        letterSpacing: letterSpacing,
        maxScale: maxScale,
        minScale: minScale,
      );

  /// Warning color (orange, for alerts)
  Color get warningColor => AppThemes.warningColor;

  /// Divider color for list/item separators
  Color get dividerColor => borderColor;
}

/// Price-related extensions for double values
extension PriceExtensions on double {
  /// Get appropriate color for price changes
  Color getPriceColor(BuildContext context) {
    if (this > 0) return context.priceUpColor;
    if (this < 0) return context.priceDownColor;
    return context.textSecondary;
  }

  /// Get price indicator (+ or -)
  String getPriceIndicator() {
    if (this > 0) return '+';
    if (this < 0) return '';
    return '';
  }

  /// Format as price with 2 decimal places
  String toPrice() {
    return toStringAsFixed(2);
  }

  /// Format as percentage with 2 decimal places
  String toPercentage() {
    return '${toStringAsFixed(2)}%';
  }
}
