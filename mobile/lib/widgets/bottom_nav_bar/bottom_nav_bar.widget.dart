import 'dart:ui';
import 'package:customer_app/pages/my_properties/my_properties.logic.dart';
import 'package:customer_app/pages/projects/projects.logic.dart';
import 'package:customer_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme.dart';
import '../../utils/l10n_extension.dart';
import '../../providers/fab_provider.dart';
import '../../pages/home/home.logic.dart';
import '../../routes/app_routes.dart';
import '../../config/feature_flags.dart';

// ─── Tab descriptor ────────────────────────────────────────────────────────────

typedef _TabItem = ({
  int index,
  IconData icon,
  IconData activeIcon,
  String label,
});

// ─── Constants ─────────────────────────────────────────────────────────────────

const _kNavBarHeight = 65.0;
const _kNavBarRadius = 40.0;
const _kAnimDuration = Duration(milliseconds: 250);

// ─── Widget ────────────────────────────────────────────────────────────────────

class BottomNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tabs = <_TabItem>[
      (
        index: 0,
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l10n.home,
      ),
      (
        index: 1,
        icon: Icons.business_outlined,
        activeIcon: Icons.business_rounded,
        label: l10n.projects,
      ),
      (
        index: 2,
        icon: Icons.bookmark_outline_rounded,
        activeIcon: Icons.bookmark_rounded,
        label: l10n.booked,
      ),
      (
        index: 3,
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: l10n.profile,
      ),
    ];

    int uiIndex = tabs.indexWhere(
      (e) => e.index == navigationShell.currentIndex,
    );
    if (uiIndex == -1) uiIndex = 0;

    final fabVisible = ref.watch(fabVisibleProvider);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      // ── FAB — only on Home tab ──────────────────────────────────────────────
      floatingActionButton: (navigationShell.currentIndex == 0 && FeatureFlags.enableSupport)
          ? AnimatedOpacity(
              opacity: fabVisible ? 1.0 : 0.0,
              duration: _kAnimDuration,
              child: IgnorePointer(
                ignoring: !fabVisible,
                child: _ContactFab(
                  onPressed: () => _showContactBottomSheet(context, ref),
                ),
              ),
            )
          : null,
      // ── Bottom Nav Bar ──────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_kNavBarRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: _kNavBarHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_kNavBarRadius),
                  color: AppTheme.white.withValues(alpha: .88),
                  border: Border.all(
                    color: AppTheme.white.withValues(alpha: .30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.black.withValues(alpha: .08),
                      blurRadius: 24,
                      spreadRadius: -2,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(tabs.length, (i) {
                    return Expanded(
                      child: _NavItem(
                        tab: tabs[i],
                        selected: i == uiIndex,
                        onTap: () => _onTabTap(ref, tabs[i]),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab tap handler ───────────────────────────────────────────────────────

  void _onTabTap(WidgetRef ref, _TabItem tab) {
    if (navigationShell.currentIndex != tab.index) {
      switch (tab.index) {
        case 0:
          ref.read(homeLogicProvider.notifier).loadData();
        case 1:
          ref.read(projectsLogicProvider.notifier).clearSearchAndReload();
        case 2:
          ref.read(myPropertiesLogicProvider.notifier).load(isRefresh: true);
        case 3:
          ref.invalidate(customerProvider);
      }
    } else {
      // If user taps the active tab, refresh it
      if (tab.index == 0) {
        ref.read(homeLogicProvider.notifier).loadData();
      } else if (tab.index == 1) {
        ref.read(projectsLogicProvider.notifier).clearSearchAndReload();
      } else if (tab.index == 2) {
        ref.read(myPropertiesLogicProvider.notifier).load(isRefresh: true);
      }
    }

    navigationShell.goBranch(
      tab.index,
      initialLocation: tab.index == navigationShell.currentIndex,
    );
  }

  // ── Contact bottom sheet ──────────────────────────────────────────────────

  void _showContactBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ContactBottomSheet(ref: ref, parentContext: context),
    );
  }
}

// ─── FAB ───────────────────────────────────────────────────────────────────────

class _ContactFab extends StatelessWidget {
  final VoidCallback onPressed;

  const _ContactFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.navyGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.midnightNavy.withValues(alpha: .35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.white,
        elevation: 0,
        highlightElevation: 0,
        onPressed: onPressed,
        child: const Icon(Icons.support_agent_rounded, size: 26),
      ),
    );
  }
}

// ─── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final _TabItem tab;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = AppTheme.midnightNavy;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Material(
        color: AppTheme.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          splashColor: primary.withValues(alpha: .08),
          highlightColor: AppTheme.transparent,
          onTap: onTap,
          child: AnimatedContainer(
            duration: _kAnimDuration,
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: selected
                  ? primary.withValues(alpha: .10)
                  : AppTheme.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: _kAnimDuration,
                  scale: selected ? 1.12 : 1.0,
                  child: AnimatedSwitcher(
                    duration: _kAnimDuration,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Icon(
                      selected ? tab.activeIcon : tab.icon,
                      key: ValueKey(selected),
                      size: 24,
                      color: selected ? primary : AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: _kAnimDuration,
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? primary : AppTheme.textSecondary,
                    letterSpacing: selected ? 0.2 : 0,
                  ),
                  child: Text(tab.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Contact Bottom Sheet ──────────────────────────────────────────────────────

class _ContactBottomSheet extends StatelessWidget {
  final WidgetRef ref;
  final BuildContext parentContext;

  const _ContactBottomSheet({required this.ref, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    final l10n = parentContext.l10n;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.midnightNavy.withValues(alpha: .08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      color: AppTheme.midnightNavy,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.howCanWeHelp,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.quickActions,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Cards
              _ContactCard(
                icon: Icons.chat_rounded,
                iconGradient: AppTheme.whatsAppGradient,
                title: l10n.whatsapp,
                subtitle: l10n.whatsappSubtitle,
                onTap: () async {
                  Navigator.pop(context);
                  final state = ref.read(homeLogicProvider);
                  final number = state.contactWhatsapp;
                  if (number == null || number.isEmpty) return;
                  final uri = Uri.parse('https://wa.me/$number');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 12),
              _ContactCard(
                icon: Icons.phone_in_talk_rounded,
                iconGradient: AppTheme.navyGradient,
                title: l10n.callUs,
                subtitle: l10n.callUsSubtitle,
                onTap: () async {
                  Navigator.pop(context);
                  final state = ref.read(homeLogicProvider);
                  final phone = state.contactPhone;
                  if (phone == null || phone.isEmpty) return;
                  final uri = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
              const SizedBox(height: 12),
              _ContactCard(
                icon: Icons.assignment_turned_in_rounded,
                iconGradient: AppTheme.goldGradient,
                title: l10n.enquireNow,
                subtitle: l10n.submitEnquiry,
                onTap: () {
                  Navigator.pop(context);
                  parentContext.push(AppRoutes.enquiry);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Contact Card ──────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Gradient iconGradient;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.midnightNavy.withValues(alpha: .05),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: iconGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .10),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: AppTheme.white, size: 22),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
