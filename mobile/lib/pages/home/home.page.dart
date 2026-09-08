import 'package:customer_app/config/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show HookConsumerWidget;
import 'home.logic.dart';
import '../../widgets/property_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/section_header.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/offer_card.dart';
import 'package:flutter/rendering.dart';
import '../../providers/fab_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../routes/app_routes.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(homeLogicProvider);
    final logic = ref.read(homeLogicProvider.notifier);
    final locale = ref.watch(localeControllerProvider);

    useEffect(() {
      Future.microtask(() {
        logic.loadData();
      });
      return null;
    }, [locale.languageCode]);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: ColorFiltered(
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          child: Image.asset(
            'assets/logo_with_vtext.png',
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              _showLanguageBottomSheet(context, ref, locale.languageCode);
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              final unreadCount =
                  ref.watch(unreadNotificationsCountProvider).value ?? 0;
              return IconButton(
                icon: unreadCount > 0
                    ? Badge(
                        label: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  context.push(AppRoutes.notifications);
                },
              );
            },
          ),
        ],
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.direction == ScrollDirection.forward) {
            if (!ref.read(fabVisibleProvider)) {
              ref.read(fabVisibleProvider.notifier).setVisible(true);
            }
          } else if (notification.direction == ScrollDirection.reverse) {
            if (ref.read(fabVisibleProvider)) {
              ref.read(fabVisibleProvider.notifier).setVisible(false);
            }
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: logic.loadData,
          child: CustomScrollView(
            slivers: [
              // ── Latest Offers ──────────────────────────────────────────────
              if (state.isLoading || state.offers.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.md,
                    ),
                    child: SectionHeader(
                      title: loc.offers,
                      actionLabel: null,
                      onAction: null,
                    ),
                  ),
                ),
              if (state.isLoading || state.offers.isNotEmpty)
                SliverToBoxAdapter(
                  child: state.isLoading
                      ? CarouselSlider(
                          options: CarouselOptions(
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.9,
                            enableInfiniteScroll: false,
                            padEnds: true,
                          ),
                          items: [
                            for (var i = 0; i < 3; i++)
                              const Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: OfferCardSkeleton(isBanner: true),
                                ),
                              ),
                          ],
                        )
                      : CarouselSlider(
                          options: CarouselOptions(
                            aspectRatio: 16 / 9,
                            viewportFraction: 0.9,
                            enableInfiniteScroll: false,
                            padEnds: true,
                            autoPlay: true,
                          ),
                          items: [
                            for (
                              var i = 0;
                              i <
                                  (state.offers.length > 6
                                      ? 6
                                      : state.offers.length);
                              i++
                            )
                              Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: OfferCard(
                                    offer: state.offers[i],
                                    onTap: () {
                                      final offer = state.offers[i];
                                      context.push(
                                        AppRoutes.offerDetails(offer.id),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),

              // ── Featured Projects (Vertical List) ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    // AppSpacing.section,
                    0,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: SectionHeader(
                    title: loc.featuredProjects,
                    actionLabel: context.l10n.viewAll,
                    onAction: () => context.push(AppRoutes.projects),
                  ),
                ),
              ),
              if (state.isLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.only(
                        bottom: AppSpacing.lg,
                        left: AppSpacing.lg,
                        right: AppSpacing.lg,
                      ),
                      child: ProjectCardSkeleton(),
                    ),
                    childCount: 3,
                  ),
                )
              else if (state.isError)
                SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: AppTheme.textSecondary,
                          size: 40,
                        ),
                        AppSpacing.hSm,
                        Text(context.l10n.unableToLoadProjects),
                        TextButton(
                          onPressed: logic.loadData,
                          child: Text(context.l10n.commonRetry),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final project = state.projects[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.lg,
                          left: AppSpacing.lg,
                          right: AppSpacing.lg,
                        ),
                        child: PropertyCard(
                          project: project,
                          onTap: () => context.push(
                            AppRoutes.projectDetails(project.id),
                          ),
                        ),
                      );
                    },
                    childCount: state.projects.length > 10
                        ? 10
                        : state.projects.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
      extendBody: true,
    ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  void _showLanguageBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String currentLanguageCode,
  ) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final l10n = context.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildLanguageOption(
                  ctx,
                  ref,
                  l10n.langEnglish,
                  'en',
                  currentLanguageCode == 'en',
                ),
                const SizedBox(height: 12),
                _buildLanguageOption(
                  ctx,
                  ref,
                  l10n.langHindi,
                  'hi',
                  currentLanguageCode == 'hi',
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    String code,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(localeControllerProvider.notifier).setLocale(code);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : AppTheme.neutral300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
              : AppTheme.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
