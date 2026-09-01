import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/theme.dart';
import '../theme/spacing.dart';

/// Shimmer skeleton for a Project/Property card.
class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: AppTheme.neutral200,
        highlightColor: AppTheme.neutral100,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(color: AppTheme.surface),
            ),
            Padding(
              padding: AppSpacing.allLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(height: 18, width: double.infinity),
                  AppSpacing.hSm,
                  _ShimmerBox(height: 14, width: 150),
                  AppSpacing.hMd,
                  Divider(),
                  AppSpacing.hMd,
                  Row(
                    children: [
                      _ShimmerBox(height: 12, width: 80),
                      Spacer(),
                      _ShimmerBox(height: 12, width: 80),
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

/// Shimmer skeleton for a Plot card.
class PlotCardSkeleton extends StatelessWidget {
  const PlotCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Shimmer.fromColors(
        baseColor: AppTheme.neutral200,
        highlightColor: AppTheme.neutral100,
        child: const Padding(
          padding: AppSpacing.allLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ShimmerBox(height: 18, width: 100),
                  _ShimmerBox(height: 22, width: 80, radius: AppRadius.pill),
                ],
              ),
              AppSpacing.hMd,
              Divider(),
              AppSpacing.hMd,
              _ShimmerBox(height: 14, width: 120),
              AppSpacing.hSm,
              _ShimmerBox(height: 14, width: 100),
              AppSpacing.hLg,
              _ShimmerBox(height: 24, width: 140),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer skeleton for a horizontal offer card.
class OfferCardSkeleton extends StatelessWidget {
  const OfferCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppRadius.circularLg,
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withValues(alpha: 0.1),
            blurRadius: 5,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: AppTheme.neutral200,
        highlightColor: AppTheme.neutral100,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 21 / 9,
              child: ColoredBox(color: AppTheme.surface),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(height: 20, width: 100),
                  AppSpacing.hSm,
                  _ShimmerBox(height: 22, width: double.infinity),
                  AppSpacing.hXs,
                  _ShimmerBox(height: 16, width: 220),
                  AppSpacing.hXs,
                  _ShimmerBox(height: 16, width: 160),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentListTileSkeleton extends StatelessWidget {
  const DocumentListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Shimmer.fromColors(
      baseColor: AppTheme.neutral200,
      highlightColor: AppTheme.neutral100,
      child: const Row(
        children: [
          _ShimmerBox(height: 24, width: 24, radius: 12),
          AppSpacing.wMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(height: 14, width: 180),
                AppSpacing.hSm,
                _ShimmerBox(height: 11, width: 70),
              ],
            ),
          ),
          _ShimmerBox(height: 24, width: 24, radius: 12),
        ],
      ),
    ),
  );
}

class NotificationListTileSkeleton extends StatelessWidget {
  const NotificationListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) => _shimmerCard(
    const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(height: 14, width: 150),
              AppSpacing.hSm,
              _ShimmerBox(height: 11, width: double.infinity),
              AppSpacing.hXs,
              _ShimmerBox(height: 11, width: 210),
            ],
          ),
        ),
        AppSpacing.wMd,
        _ShimmerBox(height: 20, width: 20, radius: 10),
      ],
    ),
  );
}

class PaymentCardSkeleton extends StatelessWidget {
  const PaymentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => _shimmerCard(
    const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _ShimmerBox(height: 16, width: 180)),
            Spacer(),
            _ShimmerBox(height: 16, width: 70),
          ],
        ),
        AppSpacing.hMd,
        Row(
          children: [
            Expanded(child: _ShimmerBox(height: 11, width: 130)),
            _ShimmerBox(height: 14, width: 64, radius: 8),
          ],
        ),
      ],
    ),
  );
}

class PropertyListTileSkeleton extends StatelessWidget {
  const PropertyListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) => _shimmerCard(
    const Row(
      children: [
        _ShimmerBox(height: 72, width: 92),
        AppSpacing.wMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(height: 16, width: 170),
              AppSpacing.hSm,
              _ShimmerBox(height: 12, width: 120),
              AppSpacing.hSm,
              _ShimmerBox(height: 12, width: 90),
            ],
          ),
        ),
      ],
    ),
  );
}

class DetailPageSkeleton extends StatelessWidget {
  const DetailPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: AppSpacing.allMd,
    children: [
      Shimmer.fromColors(
        baseColor: AppTheme.neutral200,
        highlightColor: AppTheme.neutral100,
        child: const _ShimmerBox(
          height: 220,
          width: double.infinity,
          radius: 12,
        ),
      ),
      AppSpacing.hMd,
      _shimmerCard(
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(height: 22, width: 220),
            AppSpacing.hMd,
            _ShimmerBox(height: 14, width: double.infinity),
            AppSpacing.hSm,
            _ShimmerBox(height: 14, width: 180),
            AppSpacing.hLg,
            Row(
              children: [
                Expanded(
                  child: _ShimmerBox(height: 70, width: double.infinity),
                ),
                AppSpacing.wSm,
                Expanded(
                  child: _ShimmerBox(height: 70, width: double.infinity),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _shimmerCard(Widget child) => Card(
  child: Padding(
    padding: AppSpacing.allMd,
    child: Shimmer.fromColors(
      baseColor: AppTheme.neutral200,
      highlightColor: AppTheme.neutral100,
      child: child,
    ),
  ),
);

// ─── Private helper ──────────────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double? radius;

  const _ShimmerBox({required this.height, required this.width, this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(radius ?? AppRadius.sm),
      ),
    );
  }
}
