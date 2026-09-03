import 'package:customer_app/utils/l10n_extension.dart';
import 'package:flutter/material.dart';
import '../models/plot_status.dart';
import '../theme/theme.dart';
import '../theme/spacing.dart';

/// Status badge matching the brand design system.
/// Colors: green=available, amber=hold, red=booked.
class StatusBadge extends StatelessWidget {
  final PlotStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case PlotStatus.available:
        bg = AppTheme.success.withValues(alpha: 0.12);
        fg = AppTheme.success;
        label = context.l10n.available;
      case PlotStatus.hold:
        bg = AppTheme.warning.withValues(alpha: 0.12);
        fg = AppTheme.warning;
        label = context.l10n.hold;
      case PlotStatus.bookedSold:
        bg = AppTheme.error.withValues(alpha: 0.12);
        fg = AppTheme.error;
        label = context.l10n.booked;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.circularPill,
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
