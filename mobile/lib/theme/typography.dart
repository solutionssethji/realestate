import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Real Estate Typography System utilizing Google Fonts (Outfit).
class AppTypography {
  static TextTheme get textTheme {
    return GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
