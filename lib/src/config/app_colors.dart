import 'package:flutter/material.dart';

abstract class AppColors {
  // Backgrounds
  static final Color scaffoldBackground = Colors.grey.withValues(alpha: 0.1);

  // AppBar
  static final Color appBarBackground = Colors.green[300]!;
  static const Color appBarForeground = Colors.white;

  // Text
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.black54;

  // Input
  static const Color inputBorder = Colors.black;
  static const Color inputBorderFocused = Colors.black;
  static const Color inputBorderEnabled = Colors.black54;

  // Icon
  static final Color foregroundIcon = Colors.green[300]!;

  // Button
  static const Color backGroundButton = Colors.green;
  static const Color foregroundButton = Colors.white;

  // ColorScheme
  static const Color primary = Colors.black;
  static const Color onPrimary = Colors.black;
}
