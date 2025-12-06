import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yummy/core/themes/app_colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color.fromARGB(240, 255, 255, 255),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      titleLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cardLight,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 4,
      surfaceTintColor: AppColors.primary,
      toolbarHeight: 64,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      iconTheme: IconThemeData(color: AppColors.textDark, size: 22),
      actionsIconTheme: IconThemeData(color: AppColors.textDark, size: 22),
    ),
    cardColor: AppColors.cardLight,
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.03),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerColor: Colors.black.withValues(alpha: 0.06),
    iconTheme: const IconThemeData(color: AppColors.textDark),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: Colors.transparent,
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData?>((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: AppColors.primary);
        }
        return const IconThemeData(color: AppColors.textDark);
      }),
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle?>((states) {
        final base = GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
        if (states.contains(MaterialState.selected)) {
          return base.copyWith(color: AppColors.primary);
        }
        return base.copyWith(color: AppColors.textDark.withValues(alpha: 0.7));
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: const Color.fromARGB(255, 207, 208, 211),
      surface: AppColors.cardLight,
      onPrimary: AppColors.textLight,
      onSurface: AppColors.textDark,
    ),
  );
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F1014),
    primaryColor: AppColors.primaryDark,
    textTheme: GoogleFonts.poppinsTextTheme(const TextTheme()).apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF14161C),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 4,
      surfaceTintColor: AppColors.primary,
      toolbarHeight: 64,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white, size: 22),
      actionsIconTheme: IconThemeData(color: Colors.white, size: 22),
    ),
    cardColor: AppColors.darkCard,
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorderDark),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: Colors.transparent,
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData?>((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: AppColors.primary);
        }
        return const IconThemeData(color: AppColors.textSecondaryDark);
      }),
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle?>((states) {
        final base = GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
        if (states.contains(MaterialState.selected)) {
          return base.copyWith(color: AppColors.primary);
        }
        return base.copyWith(color: AppColors.textSecondaryDark);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.cardBorderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.cardBorderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: const Color.fromARGB(255, 207, 208, 211),
      surface: AppColors.darkCard,
      onPrimary: AppColors.textLight,
      onSurface: AppColors.textPrimaryDark,
    ),
  );
}
