import 'package:flutter/material.dart';
import '../theme/spacing.dart';

class FeedbackBanner extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const FeedbackBanner({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.allMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.circularMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.error_outline, color: color, size: 18),
          AppSpacing.wSm,
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
