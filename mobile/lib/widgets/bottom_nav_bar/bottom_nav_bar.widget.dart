import 'dart:ui';
import 'package:customer_app/pages/my_properties/my_properties.logic.dart';
import 'package:customer_app/pages/projects/projects.logic.dart';
import 'package:customer_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme.dart';
import '../../utils/l10n_extension.dart';
import '../../providers/fab_provider.dart';
import '../../pages/home/home.logic.dart';
import '../../routes/app_routes.dart';

class BottomNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = [
      (
        index: 0,
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: context.l10n.home,
      ),
      (
        index: 1,
        icon: Icons.business_outlined,
        activeIcon: Icons.business,
        label: context.l10n.projects,
      ),
      (
        index: 2,
        icon: Icons.bookmark_outline,
        activeIcon: Icons.bookmark,
        label: context.l10n.booked,
      ),
      (
        index: 3,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: context.l10n.profile,
      ),
    ];

    int uiIndex = tabs.indexWhere(
      (e) => e.index == navigationShell.currentIndex,
    );
    if (uiIndex == -1) uiIndex = 0;

    const primaryColor = AppTheme.midnightNavy;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      floatingActionButton: navigationShell.currentIndex == 0
          ? AnimatedOpacity(
              opacity: ref.watch(fabVisibleProvider) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: !ref.watch(fabVisibleProvider),
                child: SpeedDial(
                  icon: Icons.add,
                  activeIcon: Icons.close,
                  spacing: 3,
                  spaceBetweenChildren: 4,
                  backgroundColor: AppTheme.midnightNavy,
                  foregroundColor: Colors.white,
                  elevation: 4.0,
                  animationCurve: Curves.easeInOut,
                  animationDuration: const Duration(milliseconds: 250),
                  children: [
                    SpeedDialChild(
                      child: const Icon(Icons.chat, color: Colors.white),
                      backgroundColor: const Color(0xFF25D366),
                      label: 'WhatsApp',
                      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                      onTap: () async {
                        final state = ref.read(homeLogicProvider);
                        final whatsapp = state.contactWhatsapp;
                        if (whatsapp == null || whatsapp.isEmpty) return;
                        final Uri uri = Uri.parse('https://wa.me/$whatsapp');
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(Icons.phone, color: Colors.white),
                      backgroundColor: AppTheme.midnightNavy,
                      label: 'Call',
                      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                      onTap: () async {
                        final state = ref.read(homeLogicProvider);
                        final phone = state.contactPhone;
                        if (phone == null || phone.isEmpty) return;
                        final uri = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(uri)) await launchUrl(uri);
                      },
                    ),
                    SpeedDialChild(
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                      ),
                      backgroundColor: AppTheme.midnightNavy,
                      label: context.l10n.enquireNow,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                      onTap: () => context.push(AppRoutes.enquiry),
                    ),
                  ],
                ),
              ),
            )
          : null,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 8,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                height: 65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white.withValues(alpha: .85),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.black.withValues(alpha: .08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final tab = tabs[index];
                    final isSelected = index == uiIndex;

                    return Expanded(
                      child: _buildItem(
                        context: context,
                        tab: tab,
                        selected: isSelected,
                        primaryColor: primaryColor,
                        onTap: () {
                          if (navigationShell.currentIndex != tab.index) {
                            if (tab.index == 0) {
                              ref.read(homeLogicProvider.notifier).loadData();
                            } else if (tab.index == 1) {
                              ref
                                  .read(projectsLogicProvider.notifier)
                                  .loadProjects();
                            } else if (tab.index == 2) {
                              ref
                                  .read(myPropertiesLogicProvider.notifier)
                                  .load(isRefresh: true);
                            } else if (tab.index == 3) {
                              ref.invalidate(customerProvider);
                            }
                          }
                          navigationShell.goBranch(
                            tab.index,
                            initialLocation:
                                tab.index == navigationShell.currentIndex,
                          );
                        },
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

  Widget _buildItem({
    required BuildContext context,
    required ({int index, IconData icon, IconData activeIcon, String label})
    tab,
    required bool selected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          splashColor: primaryColor.withValues(alpha: .08),
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: selected
                  ? primaryColor.withValues(alpha: .10)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  scale: selected ? 1.12 : 1,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      selected ? tab.activeIcon : tab.icon,
                      key: ValueKey(selected),
                      size: 24,
                      color: selected ? primaryColor : AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? primaryColor : AppTheme.textSecondary,
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
