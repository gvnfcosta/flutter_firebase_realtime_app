import 'package:flutter/material.dart';

final ColorScheme _colorScheme = ColorScheme.fromSeed(
  seedColor: Color(0xFF00695C), // teal principal
  primary: Color(0xFF00695C), // teal escuro
  secondary: const Color(0xFF4DB6AC), // teal claro
  tertiary: const Color(0xFF26A69A), // intermediário
  surface: Colors.white,
  onPrimary: Colors.white,
  onSecondary: Colors.black87,
  onSurface: Colors.black87,
  brightness: Brightness.light,
);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _colorScheme,
  scaffoldBackgroundColor: _colorScheme.surface,

  // AppBar controlada pelo tema
  appBarTheme: AppBarTheme(
    backgroundColor: _colorScheme.primary,
    foregroundColor: _colorScheme.onPrimary,
    elevation: 1,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: _colorScheme.onPrimary,
    ),
    toolbarTextStyle: TextStyle(color: _colorScheme.onPrimary, fontSize: 16),
    iconTheme: IconThemeData(color: _colorScheme.onPrimary),
  ),

  // Botões padronizados
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _colorScheme.primary,
      foregroundColor: _colorScheme.onPrimary,
      disabledBackgroundColor: _colorScheme.primary.withAlpha(100),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
      elevation: 3,
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _colorScheme.primary,
      side: BorderSide(color: _colorScheme.primary, width: 1.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  // Campos de texto
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: _colorScheme.primary.withValues(alpha: 0.4),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _colorScheme.primary, width: 1.5),
    ),
    labelStyle: TextStyle(color: _colorScheme.primary),
    hintStyle: TextStyle(color: Colors.black54),
    prefixIconColor: _colorScheme.primary,
  ),

  // Cartões e superfícies
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    shadowColor: _colorScheme.primary.withValues(alpha: 0.2),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  ),

  // Texto
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Color(0xFF004D40), // teal escuro
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF00695C), // teal principal
    ),
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(fontSize: 15, color: Colors.black87),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
    bodySmall: TextStyle(fontSize: 13, color: Colors.black54),
  ),

  //TextButton
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _colorScheme.secondary, // 🔹 cor do texto e ícone
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),

  // Ícones
  iconTheme: IconThemeData(color: _colorScheme.primary),

  // SnackBar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: _colorScheme.primary,
    contentTextStyle: TextStyle(color: _colorScheme.onPrimary),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
