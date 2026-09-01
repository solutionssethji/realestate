import 'package:flutter/material.dart';
import '../theme/spacing.dart';

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const SkeletonList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = AppSpacing.allLg,
    this.spacing = AppSpacing.lg,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(height: spacing),
      itemBuilder: itemBuilder,
    );
  }
}
