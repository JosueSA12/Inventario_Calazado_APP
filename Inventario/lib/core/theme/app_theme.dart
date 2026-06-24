import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.surface,
      ),
      useMaterial3: true,
      subThemesData: const FlexSubThemesData(
        cardRadius: 16.0,
        buttonPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        background: Color(0xFF1A1613),
        surface: Color(0xFF25201C),
      ),
      useMaterial3: true,
      subThemesData: const FlexSubThemesData(cardRadius: 16.0),
    );
  }
}
