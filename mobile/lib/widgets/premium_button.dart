import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../theme/spacing.dart';

enum PremiumButtonStyle { primary, secondary, outline, ghost }

/// Reusable premium button that maps to the brand design system.
/// Supports loading state, icon, full-width, and four visual variants.
class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final PremiumButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = PremiumButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), AppSpacing.wSm],
              Text(text),
            ],
          );

    Widget button;
    switch (style) {
      case PremiumButtonStyle.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppTheme.midnightNavy,
            foregroundColor: foregroundColor ?? AppTheme.white,
          ),
          child: child,
        );
      case PremiumButtonStyle.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppTheme.softGold,
            foregroundColor: foregroundColor ?? AppTheme.midnightNavy,
          ),
          child: child,
        );
      case PremiumButtonStyle.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            side: backgroundColor != null
                ? BorderSide(color: backgroundColor!)
                : null,
          ),
          child: child,
        );
      case PremiumButtonStyle.ghost:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
          ),
          child: child,
        );
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
