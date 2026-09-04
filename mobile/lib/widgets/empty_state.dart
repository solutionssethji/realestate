import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../theme/spacing.dart';

/// Polished empty state with optional retry CTA.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.icon = Icons.search_off_rounded,
    required this.title,
    this.message,
    this.buttonText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.section),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.allLg,
              decoration: BoxDecoration(
                color: AppTheme.border.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppTheme.textSecondary),
            ),
            AppSpacing.hXl,
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppTheme.midnightNavy),
              textAlign: TextAlign.center,
            ),
            if (message != null && message!.isNotEmpty) ...[
              AppSpacing.hSm,
              Text(
                message!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onAction != null) ...[
              AppSpacing.hXl,
              OutlinedButton(onPressed: onAction, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}
