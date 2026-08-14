import 'package:flutter/material.dart';
import '../models/plot.dart';
import '../theme/theme.dart';
import '../theme/spacing.dart';
import 'status_badge.dart';
import '../utils/l10n_extension.dart';

/// Premium plot card for grid view.
class PlotCard extends StatelessWidget {
  final Plot plot;
  final VoidCallback onTap;

  const PlotCard({super.key, required this.plot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: AppSpacing.allLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.plotTitle(plot.plotNumber),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  StatusBadge(status: plot.status),
                ],
              ),
              AppSpacing.hMd,
              const Divider(height: 1),
              AppSpacing.hMd,
              _Row(
                icon: Icons.square_foot,
                label: context.l10n.sqFtLabel(
                  plot.sizeInSqFt.toStringAsFixed(0),
                ),
              ),
              AppSpacing.hXs,
              _Row(
                icon: Icons.explore_outlined,
                label: context.l10n.facingLabelCard(plot.facing),
              ),
              const Spacer(),
              Text(
                '₹${plot.price.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.midnightNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Row({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        AppSpacing.wXs,
        Flexible(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
