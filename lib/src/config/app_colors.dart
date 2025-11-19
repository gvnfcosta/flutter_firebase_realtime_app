import 'package:flutter/material.dart';

abstract class AppColors {
  // Backgrounds
  static final Color scaffoldBackground = Colors.grey.withValues(alpha: 0.1);
  static final Color backGroundColor = Colors.teal;

  // AppBar
  static final Color appBarBackground = Colors.teal;
  static const Color appBarForeground = Colors.white;

  // Text
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.black54;
  static const Color textTertiary = Colors.black38;

  // Input
  static const Color inputBorder = Colors.black;
  static const Color inputBorderFocused = Colors.black;
  static const Color inputBorderEnabled = Colors.black54;

  // Icon
  static final Color foregroundIcon = Colors.teal[300]!;

  // Button
  static const Color backGroundButton = Colors.teal;
  static const Color foregroundButton = Colors.white;
  static final Color disabledBackgroundColor = Colors.grey[300]!;

  // ColorScheme
  static const Color primary = Colors.black;
  static const Color onPrimary = Colors.black;
  static const Color secondry = Colors.black45;

  //LinearGradient
  static final Color linearPimary = Colors.teal;
  static final Color linearSecondary = Colors.teal[200]!;
  static final Color linearTerceiary = Colors.white;
}
