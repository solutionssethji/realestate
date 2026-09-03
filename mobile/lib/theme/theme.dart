import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'typography.dart';
import 'spacing.dart';

/// Shared brand and fallback color tokens.
///
/// Theme-dependent UI colors should use BuildContext.colorScheme so dark theme
/// changes can update them automatically.
class AppColors {
  static const Color primary = Color(0xFF355E70);
  static const Color primaryDark = Color(0xFF2A4B59);
  static const Color accent = Color(0xFFD4AF37);
  static const Color accentDark = Color(0xFFB8972E);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1B323C);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Social / Utility
  static const Color whatsAppGreen = Color(0xFF25D366);
  static const Color whatsAppDark = Color(0xFF128C7E);

  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color black = Colors.black;
  static const Color black54 = Colors.black54;
  static const Color transparent = Colors.transparent;
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
}

class AppTheme {
  // Brand Colors - Primary (#355E70) & Soft Gold
  static const Color midnightNavy = AppColors.primary;
  static const Color slateBlue = AppColors.primaryDark;
  static const Color softGold = AppColors.accent;
  static const Color darkGold = AppColors.accentDark;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color border = AppColors.border;

  // Social / Utility
  static const Color whatsAppGreen = AppColors.whatsAppGreen;
  static const Color whatsAppDark = AppColors.whatsAppDark;

  // Status Colors
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color error = AppColors.error;
  static const Color info = AppColors.info;
  static const Color white = AppColors.white;
  static const Color white70 = AppColors.white70;
  static const Color black = AppColors.black;
  static const Color black54 = AppColors.black54;
  static const Color transparent = AppColors.transparent;
  static const Color neutral50 = AppColors.neutral50;
  static const Color neutral100 = AppColors.neutral100;
  static const Color neutral200 = AppColors.neutral200;
  static const Color neutral300 = AppColors.neutral300;
  static const Color neutral400 = AppColors.neutral400;
  static const Color neutral500 = AppColors.neutral500;
  static const Color neutral600 = AppColors.neutral600;

  // Brand Gradients
  static const LinearGradient whatsAppGradient = LinearGradient(
    colors: [AppColors.whatsAppGreen, AppColors.whatsAppDark],
  );
  static const LinearGradient navyGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
  );
  static const LinearGradient goldGradient = LinearGradient(
    colors: [AppColors.accent, AppColors.accentDark],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: midnightNavy,
        primary: midnightNavy,
        secondary: softGold,
        surface: surface,
        error: error,
        onPrimary: AppColors.white,
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
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: midnightNavy,
        ),
        iconTheme: const IconThemeData(color: midnightNavy),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: AppColors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circularLg,
          side: BorderSide.none,
        ),
        color: surface,
        surfaceTintColor: surface,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: midnightNavy,
          foregroundColor: AppColors.white,
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
