import 'package:flutter/material.dart';

/// GemNet — pure black & white, high-contrast luxury theme.
class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color richBlack = Color(0xFF0A0A0A);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color darkGrey = Color(0xFF2C2C2C);
  static const Color midGrey = Color(0xFF6E6E6E);
  static const Color lightGrey = Color(0xFFB8B8B8);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF3ECF6E);
  static const Color error = Color(0xFFE84C4C);
  static const Color warning = Color(0xFFE0B84C);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.black,
      primaryColor: AppColors.white,
      fontFamily: 'Georgia',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.white,
        secondary: AppColors.lightGrey,
        surface: AppColors.richBlack,
        error: AppColors.error,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onSurface: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.white),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.richBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.darkGrey, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.white, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.lightGrey),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.charcoal,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.white, width: 1.4),
        ),
        labelStyle: const TextStyle(color: AppColors.lightGrey),
        hintStyle: const TextStyle(color: AppColors.midGrey),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkGrey, thickness: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.black,
        selectedItemColor: AppColors.white,
        unselectedItemColor: AppColors.midGrey,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoal,
        contentTextStyle: const TextStyle(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.charcoal,
        labelStyle: const TextStyle(color: AppColors.white, fontSize: 12),
        side: const BorderSide(color: AppColors.darkGrey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppColors.offWhite),
        bodyMedium: TextStyle(color: AppColors.lightGrey),
        bodySmall: TextStyle(color: AppColors.midGrey),
      ),
    );
  }
}
