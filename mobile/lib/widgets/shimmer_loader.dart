import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
// import '../theme/theme.dart';
import '../theme/spacing.dart';

/// Shimmer skeleton for a Project/Property card.
class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(color: Colors.white),
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
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade100,
        child: const Row(
          children: [
            SizedBox(
              height: 140,
              width: 140,
              child: ColoredBox(color: Colors.white),
            ),
            Expanded(
              child: Padding(
                padding: AppSpacing.allLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ShimmerBox(height: 12, width: 80),
                    AppSpacing.hSm,
                    _ShimmerBox(height: 18, width: double.infinity),
                    AppSpacing.hXs,
                    _ShimmerBox(height: 18, width: 180),
                    AppSpacing.hMd,
                    _ShimmerBox(height: 12, width: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius ?? AppRadius.sm),
      ),
    );
  }
}
