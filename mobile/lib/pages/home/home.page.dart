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
import '../../routes/app_routes.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(homeLogicProvider);
    final logic = ref.read(homeLogicProvider.notifier);
    useEffect(() {
      Future.microtask(() {
        logic.loadData();
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Image.asset(
          'assets/logo_with_text.png',
          height: 60,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppTheme.midnightNavy),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
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
                      actionLabel: state.offers.length > 6
                          ? context.l10n.viewAll
                          : null,
                      onAction: state.offers.length > 6
                          ? () => context.push(AppRoutes.offers)
                          : null,
                    ),
                  ),
                ),
              if (state.isLoading || state.offers.isNotEmpty)
                SliverToBoxAdapter(
                  child: state.isLoading
                      ? CarouselSlider(
                          options: CarouselOptions(
                            height: 280,
                            viewportFraction: 0.9,
                            enableInfiniteScroll: false,
                            padEnds: true,
                          ),
                          items: [
                            for (var i = 0; i < 3; i++)
                              const Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                  child: OfferCardSkeleton(),
                                ),
                              ),
                          ],
                        )
                      : CarouselSlider(
                          options: CarouselOptions(
                            height: 280,
                            viewportFraction: 0.9,
                            enableInfiniteScroll: false,
                            padEnds: true,
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
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
                    AppSpacing.section,
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

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }
}
