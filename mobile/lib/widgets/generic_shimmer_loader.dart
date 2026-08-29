import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/theme.dart';

class ShimmerLoader extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final int count;
  final double spacing;

  const ShimmerLoader({
    super.key,
    this.height = 100,
    this.width = double.infinity,
    this.borderRadius = 8.0,
    this.count = 3,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.neutral200,
      highlightColor: AppTheme.neutral100,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(height: spacing),
        itemBuilder: (_, __) => Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}
