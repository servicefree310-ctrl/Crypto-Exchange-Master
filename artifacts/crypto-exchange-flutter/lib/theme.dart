import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF1652F0);
  static const accent = Color(0xFFFF8A00);
  static const success = Color(0xFF16A34A);
  static const danger = Color(0xFFDC2626);
  static const bg = Color(0xFF0B0E13);
  static const card = Color(0xFF131720);
  static const border = Color(0xFF1F2530);
  static const fg = Color(0xFFE8ECF1);
  static const muted = Color(0xFF8B95A5);
}

ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    primaryColor: AppColors.primary,
    cardColor: AppColors.card,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.card,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.card,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.muted,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.fg,
      displayColor: AppColors.fg,
    ),
    dividerColor: AppColors.border,
  );
}
