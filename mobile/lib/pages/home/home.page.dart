import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'home.logic.dart';
import '../../widgets/property_card.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/section_header.dart';
import '../../widgets/premium_button.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(homeLogicProvider);
    final logic = ref.read(homeLogicProvider.notifier);
    final bool isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: logic.loadProjects,
        child: CustomScrollView(
          slivers: [
            // ── Cinematic Hero ────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: isDesktop ? 560 : 420,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl:
                          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80',
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const ColoredBox(color: AppTheme.slateBlue),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            AppTheme.midnightNavy.withValues(alpha: 0.85),
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.hero,
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.findPremiumProperty,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(color: Colors.white, height: 1.15),
                          ),
                          AppSpacing.hMd,
                          Text(
                            context.l10n.exclusivePlotsDesc,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                          AppSpacing.hXl,
                          PremiumButton(
                            text: context.l10n.exploreProjects,
                            isFullWidth: false,
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () => context.push('/home/projects'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Featured Projects ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.section,
                  AppSpacing.lg,
                  0,
                ),
                child: SectionHeader(
                  title: loc.featuredProjects,
                  actionLabel: context.l10n.viewAll,
                  onAction: () => context.push('/home/projects'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 340,
                child: state.isLoading
                    ? ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: AppSpacing.horizontalLg,
                        itemCount: 3,
                        separatorBuilder: (_, __) => AppSpacing.wLg,
                        itemBuilder: (_, __) => const SizedBox(
                          width: 280,
                          child: ProjectCardSkeleton(),
                        ),
                      )
                    : state.isError
                    ? Center(
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
                              onPressed: logic.loadProjects,
                              child: Text(context.l10n.commonRetry),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: AppSpacing.horizontalLg,
                        itemCount: state.projects.length,
                        separatorBuilder: (_, __) => AppSpacing.wLg,
                        itemBuilder: (context, index) {
                          final p = state.projects[index];
                          return SizedBox(
                            width: 280,
                            child: PropertyCard(
                              project: p,
                              onTap: () =>
                                  context.push('/home/project/${p.id}'),
                            ),
                          );
                        },
                      ),
              ),
            ),

            // ── Why Choose Us ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: AppSpacing.section,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.largeSection,
                  horizontal: AppSpacing.lg,
                ),
                color: AppTheme.midnightNavy,
                child: Column(
                  children: [
                    Text(
                      context.l10n.whyInvestWithUs,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.hXXl,
                    isDesktop
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _FeatureTile(
                                icon: Icons.security,
                                title: context.l10n.secureInvestment,
                                description: context.l10n.clearTitlesProcess,
                              ),
                              AppSpacing.wXXl,
                              _FeatureTile(
                                icon: Icons.trending_up,
                                title: context.l10n.highRoi,
                                description: context.l10n.strategicLocations,
                              ),
                              AppSpacing.wXXl,
                              _FeatureTile(
                                icon: Icons.support_agent,
                                title: context.l10n.expertSupport,
                                description: context.l10n.dedicatedManagers,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _FeatureTile(
                                icon: Icons.security,
                                title: context.l10n.secureInvestment,
                                description: context.l10n.clearTitlesProcess,
                              ),
                              AppSpacing.hLg,
                              _FeatureTile(
                                icon: Icons.trending_up,
                                title: context.l10n.highRoi,
                                description: context.l10n.strategicLocations,
                              ),
                              AppSpacing.hLg,
                              _FeatureTile(
                                icon: Icons.support_agent,
                                title: context.l10n.expertSupport,
                                description: context.l10n.dedicatedManagers,
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),

            // ── Quick Actions ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.allLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: context.l10n.quickActions),
                    AppSpacing.hLg,
                    GridView.count(
                      crossAxisCount: isDesktop ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 2.2,
                      children: [
                        _QuickAction(
                          icon: Icons.landscape_outlined,
                          label: context.l10n.plotFinder,
                          onTap: () => context.push('/home/projects'),
                        ),
                        _QuickAction(
                          icon: Icons.local_offer_outlined,
                          label: loc.offers,
                          onTap: () => context.push('/home/offers'),
                        ),
                        _QuickAction(
                          icon: Icons.calculate_outlined,
                          label: loc.emiCalculator,
                          onTap: () => context.push('/home/calculator'),
                        ),
                        _QuickAction(
                          icon: Icons.directions_car_outlined,
                          label: context.l10n.siteVisit,
                          onTap: () => context.push('/home/site-visit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    //     final loc = AppLocalizations.of(context);
    return Container(
      width: 280,
      padding: AppSpacing.allLg,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: AppRadius.circularLg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppSpacing.allSm,
            decoration: BoxDecoration(
              color: AppTheme.softGold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.softGold, size: 28),
          ),
          AppSpacing.hLg,
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          AppSpacing.hXs,
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    //     final loc = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.circularMd,
      child: Container(
        padding: AppSpacing.allMd,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: AppRadius.circularMd,
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.midnightNavy, size: 22),
            AppSpacing.wSm,
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
