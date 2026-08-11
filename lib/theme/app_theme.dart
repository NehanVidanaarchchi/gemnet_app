import 'package:flutter/material.dart';

/// A refined, jewel-inspired design system used throughout GemNet.
class AppColors {
  static const black = Color(0xFF07110F);
  static const richBlack = Color(0xFF0E1A17);
  static const charcoal = Color(0xFF152521);
  static const darkGrey = Color(0xFF294039);
  static const midGrey = Color(0xFF8A9D97);
  static const lightGrey = Color(0xFFC1CEC9);
  static const offWhite = Color(0xFFF2F6F4);
  static const white = Color(0xFFFFFFFF);
  static const emerald = Color(0xFF36D39A);
  static const emeraldDark = Color(0xFF087A58);
  static const gold = Color(0xFFE6C46A);

  static const success = Color(0xFF55D99F);
  static const error = Color(0xFFFF7373);
  static const warning = Color(0xFFF2C66D);
}

class AppTheme {
  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.emerald,
      brightness: Brightness.dark,
      surface: AppColors.richBlack,
      error: AppColors.error,
    ).copyWith(
      primary: AppColors.emerald,
      secondary: AppColors.gold,
      onPrimary: AppColors.black,
      surface: AppColors.richBlack,
      onSurface: AppColors.offWhite,
      outline: AppColors.darkGrey,
    );

    const textTheme = TextTheme(
      displaySmall: TextStyle(fontSize: 36, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -1.2),
      headlineLarge: TextStyle(fontSize: 30, height: 1.15, fontWeight: FontWeight.w800, letterSpacing: -0.8),
      headlineMedium: TextStyle(fontSize: 24, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: -0.4),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: AppColors.offWhite),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: AppColors.lightGrey),
      bodySmall: TextStyle(fontSize: 12, height: 1.4, color: AppColors.midGrey),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.1),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.black,
      fontFamily: 'Roboto',
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: AppColors.offWhite, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: AppColors.richBlack,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkGrey),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.black,
          disabledBackgroundColor: AppColors.darkGrey,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.offWhite,
          minimumSize: const Size.fromHeight(54),
          side: const BorderSide(color: AppColors.darkGrey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.emerald)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.richBlack,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.darkGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.emerald, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error)),
        labelStyle: const TextStyle(color: AppColors.lightGrey),
        hintStyle: const TextStyle(color: AppColors.midGrey),
        prefixIconColor: AppColors.midGrey,
        suffixIconColor: AppColors.midGrey,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkGrey, thickness: 1),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.richBlack,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.emerald.withValues(alpha: .16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          color: states.contains(WidgetState.selected) ? AppColors.emerald : AppColors.midGrey,
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
        )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? AppColors.emerald : AppColors.midGrey,
        )),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.emerald,
        foregroundColor: AppColors.black,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoal,
        contentTextStyle: const TextStyle(color: AppColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.charcoal,
        labelStyle: const TextStyle(color: AppColors.lightGrey, fontSize: 12, fontWeight: FontWeight.w600),
        side: const BorderSide(color: AppColors.darkGrey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
