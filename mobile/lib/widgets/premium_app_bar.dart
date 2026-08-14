import 'package:flutter/material.dart';
import '../theme/theme.dart';
// import '../theme/spacing.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor = AppTheme.background,
    this.foregroundColor = AppTheme.textPrimary,
    this.elevation = 0.5,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: foregroundColor,
        ),
      ),
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: foregroundColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
