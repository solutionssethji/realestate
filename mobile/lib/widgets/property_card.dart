import 'package:flutter/material.dart';
import '../models/project.dart';
import '../theme/theme.dart';
import '../theme/spacing.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/l10n_extension.dart';

/// Premium image-first project card for grids and horizontal lists.
class PropertyCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const PropertyCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ────────────────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: project.coverImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const ColoredBox(color: AppTheme.border),
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: AppTheme.border,
                      child: Icon(
                        Icons.home_outlined,
                        color: AppTheme.textSecondary,
                        size: 48,
                      ),
                    ),
                  ),
                  // Dark gradient for price readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 64,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ),
                  // Price pill
                  Positioned(
                    bottom: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.midnightNavy.withValues(alpha: 0.88),
                        borderRadius: AppRadius.circularPill,
                      ),
                      child: Text(
                        project.priceRange,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ────────────────────────────────────────────────────────
            Padding(
              padding: AppSpacing.allLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.hXs,
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      AppSpacing.wXs,
                      Expanded(
                        child: Text(
                          project.location,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.hMd,
                  const Divider(height: 1),
                  AppSpacing.hMd,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Stat(
                        icon: Icons.landscape_outlined,
                        label: context.l10n.projectPlotsCount(
                          project.plotCount.toString(),
                        ),
                      ),
                      _Stat(
                        icon: Icons.verified_outlined,
                        label: project.developmentStatus,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.softGold),
        AppSpacing.wXs,
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppTheme.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
