import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../theme/spacing.dart';
import '../l10n/app_localizations.dart';
import '../utils/l10n_extension.dart';

/// Full-page polished error state with retry support.
class ErrorState extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, this.title, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.section),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.allLg,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: AppTheme.error,
              ),
            ),
            AppSpacing.hXl,
            Text(
              title ?? context.l10n.somethingWentWrongAlt,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppTheme.midnightNavy),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              AppSpacing.hSm,
              Text(
                message!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              AppSpacing.hXl,
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(loc.tryAgain),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
