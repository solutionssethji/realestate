import 'package:flutter/material.dart';
import 'typography.dart';
import 'spacing.dart';

class AppTheme {
  // Brand Colors - Midnight Navy & Soft Gold
  static const Color midnightNavy = Color(0xFF0F172A);
  static const Color slateBlue = Color(0xFF1E293B);
  static const Color softGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB8972E);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: midnightNavy,
        primary: midnightNavy,
        secondary: softGold,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: midnightNavy,
      ),
      scaffoldBackgroundColor: background,
      useMaterial3: true,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: midnightNavy,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: midnightNavy,
        ),
        iconTheme: const IconThemeData(color: midnightNavy),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circularLg,
          side: const BorderSide(color: border),
        ),
        color: surface,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: midnightNavy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
          elevation: 0,
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: midnightNavy,
          side: const BorderSide(color: midnightNavy, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: midnightNavy,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.circularMd,
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularMd,
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularMd,
          borderSide: const BorderSide(color: midnightNavy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularMd,
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: textSecondary,
        ),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: textSecondary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: background,
        labelStyle: AppTypography.textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circularPill,
          side: const BorderSide(color: border),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}
