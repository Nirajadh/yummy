import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized text styles to keep typography consistent.
class AppTextStyles {
  // Base text theme using Poppins across the app.
  static TextTheme textTheme(BuildContext context) {
    final base = Theme.of(context).textTheme;
    return GoogleFonts.poppinsTextTheme(base).copyWith(
      bodyLarge: GoogleFonts.poppins(
        color: base.bodyLarge?.color,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: base.bodyMedium?.color,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: GoogleFonts.poppins(
        color: base.titleLarge?.color,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      labelLarge: GoogleFonts.poppins(
        color: base.labelLarge?.color,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static TextStyle heading1({Color? color}) =>
      GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w800, color: color);

  static TextStyle heading2({Color? color}) =>
      GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: color);

  static TextStyle heading3({Color? color}) =>
      GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: color);

  static TextStyle body({Color? color}) =>
      GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: color);

  static TextStyle label({Color? color}) =>
      GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color);
}
