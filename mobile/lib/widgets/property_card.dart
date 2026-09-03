import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../theme/theme.dart';
import '../theme/spacing.dart';
import 'app_cached_image.dart';
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
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: AppRadius.circularLg,
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image with Glassmorphism Overlays ───────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppCachedImage(imageUrl: project.coverImage),
                  // Premium overlay gradient
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.black.withValues(alpha: 0.1),
                            AppTheme.transparent,
                            AppTheme.black.withValues(alpha: 0.6),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Featured Badge
                  if (project.isFeatured)
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      child: ClipRRect(
                        borderRadius: AppRadius.circularPill,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.white.withValues(alpha: 0.2),
                              borderRadius: AppRadius.circularPill,
                              border: Border.all(
                                color: AppTheme.white.withValues(alpha: 0.4),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppTheme.softGold,
                                  size: 14,
                                ),
                                AppSpacing.wXs,
                                Text(
                                  context.l10n.featured,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppTheme.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Price pill (Glassmorphism)
                  Positioned(
                    bottom: AppSpacing.md,
                    right: AppSpacing.md,
                    child: ClipRRect(
                      borderRadius: AppRadius.circularPill,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.midnightNavy.withValues(alpha: 0.7),
                            borderRadius: AppRadius.circularPill,
                            border: Border.all(
                              color: AppTheme.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            project.priceRange,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info Section ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppTheme.midnightNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.hSm,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.softGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.darkGold,
                        ),
                      ),
                      AppSpacing.wSm,
                      Expanded(
                        child: Text(
                          project.location,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.hMd,
                  // Stats with a modern aesthetic
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: AppRadius.circularMd,
                      border: Border.all(
                        color: AppTheme.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Stat(
                          icon: Icons.landscape_rounded,
                          label: context.l10n.projectPlotsCount(
                            project.plotCount.toString(),
                          ),
                        ),
                        Container(width: 1, height: 24, color: AppTheme.border),
                        _Stat(
                          icon: Icons.verified_rounded,
                          label: project.developmentStatus,
                        ),
                      ],
                    ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.midnightNavy),
        AppSpacing.wSm,
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
