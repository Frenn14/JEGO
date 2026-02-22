import 'package:flutter/material.dart';
import 'color_system.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.backgroundLight,
      brightness: Brightness.light,
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      brightness: Brightness.dark,
      useMaterial3: true,
    );
  }
}