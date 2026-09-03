import 'package:flutter/material.dart';
import '../models/plot.dart';
import '../theme/theme.dart';
import '../theme/spacing.dart';
import '../models/plot_status.dart';
import 'status_badge.dart';
import '../utils/l10n_extension.dart';
import '../utils/price_formatter.dart';

/// Premium plot card for grid view.
class PlotCard extends StatelessWidget {
  final Plot plot;
  final VoidCallback onTap;

  const PlotCard({super.key, required this.plot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (plot.status) {
      case PlotStatus.available:
        statusColor = AppTheme.success;
      case PlotStatus.hold:
        statusColor = AppTheme.warning;
      case PlotStatus.bookedSold:
        statusColor = AppTheme.error;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: AppRadius.circularLg,
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored left accent bar
              Container(width: 5, color: statusColor),
              Expanded(
                child: Padding(
                  padding: AppSpacing.allLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.plotTitle(plot.plotNumber),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AppSpacing.wSm,
                          StatusBadge(status: plot.status),
                        ],
                      ),
                      AppSpacing.hMd,
                      const Divider(height: 1, color: AppTheme.border),
                      AppSpacing.hMd,

                      // Features grid
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _FeatureChip(
                            icon: Icons.square_foot,
                            label: context.l10n.sqFtLabel(
                              plot.sizeInSqFt.toStringAsFixed(0),
                            ),
                          ),
                          if (plot.dimensions.isNotEmpty &&
                              plot.dimensions != 'N/A')
                            _FeatureChip(
                              icon: Icons.aspect_ratio,
                              label: plot.dimensions,
                            ),
                          if (plot.facing.isNotEmpty)
                            _FeatureChip(
                              icon: Icons.explore_outlined,
                              label: context.l10n.facingLabelCard(plot.facing),
                            ),
                          if (plot.roadWidth.isNotEmpty &&
                              plot.roadWidth != 'N/A')
                            _FeatureChip(
                              icon: Icons.add_road,
                              label: plot.roadWidth,
                            ),
                        ],
                      ),

                      const Spacer(),
                      AppSpacing.hMd,

                      // Price Section
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.neutral50,
                          borderRadius: AppRadius.circularMd,
                          border: Border.all(
                            color: AppTheme.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.priceLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              context.l10n.inrPrice(
                                PriceFormatter.formatNumber(plot.price),
                              ),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppTheme.midnightNavy,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        AppSpacing.wXs,
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
