import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.scaffoldBackground,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.appBarBackground,
    foregroundColor: AppColors.appBarForeground,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AppColors.textPrimary),
    bodyMedium: TextStyle(color: AppColors.textPrimary),
    titleLarge: TextStyle(color: AppColors.textPrimary),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.inputBorder),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.inputBorderEnabled),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.inputBorderFocused, width: 2),
    ),
    labelStyle: TextStyle(color: AppColors.textPrimary),
    hintStyle: TextStyle(color: AppColors.textSecondary),
  ),
);
