import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'plot_availability.logic.dart';
import '../../theme/theme.dart';
import '../../theme/spacing.dart';
import '../../models/plot_status.dart';
import '../../widgets/plot_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/shimmer_loader.dart';

class PlotAvailabilityPage extends HookConsumerWidget {
  final String projectId;

  const PlotAvailabilityPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(plotAvailabilityLogicProvider(projectId));
    final logic = ref.read(plotAvailabilityLogicProvider(projectId).notifier);
    final bool isTablet = ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final bool isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    // Live counts from allPlots for badge display
    final allCount = state.allPlots.length;
    final availableCount = state.allPlots
        .where((p) => p.status == PlotStatus.available)
        .length;
    final holdCount = state.allPlots
        .where((p) => p.status == PlotStatus.hold)
        .length;
    final bookedCount = state.allPlots
        .where((p) => p.status == PlotStatus.bookedSold)
        .length;

    return Scaffold(
      appBar: PremiumAppBar(title: loc.plotAvailability),
      body: Column(
        children: [
          // ── Search + Filters ─────────────────────────────────────────────
          Container(
            color: AppTheme.surface,
            padding: AppSpacing.allLg,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: context.l10n.searchByPlot,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: logic.updateSearch,
                ),
                AppSpacing.hLg,
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatusChip(
                        label: loc.all,
                        count: allCount,
                        isSelected: state.selectedStatusFilter == null,
                        color: AppTheme.midnightNavy,
                        onSelected: () => logic.setStatusFilter(null),
                      ),
                      AppSpacing.wSm,
                      _StatusChip(
                        label: loc.available,
                        count: availableCount,
                        isSelected:
                            state.selectedStatusFilter == PlotStatus.available,
                        color: AppTheme.success,
                        onSelected: () =>
                            logic.setStatusFilter(PlotStatus.available),
                      ),
                      AppSpacing.wSm,
                      _StatusChip(
                        label: loc.hold,
                        count: holdCount,
                        isSelected:
                            state.selectedStatusFilter == PlotStatus.hold,
                        color: AppTheme.warning,
                        onSelected: () =>
                            logic.setStatusFilter(PlotStatus.hold),
                      ),
                      AppSpacing.wSm,
                      _StatusChip(
                        label: loc.booked,
                        count: bookedCount,
                        isSelected:
                            state.selectedStatusFilter == PlotStatus.bookedSold,
                        color: AppTheme.error,
                        onSelected: () =>
                            logic.setStatusFilter(PlotStatus.bookedSold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Results Summary Bar ───────────────────────────────────────────
          if (!state.isLoading && !state.isError && state.allPlots.isNotEmpty)
            Container(
              width: double.infinity,
              color: AppTheme.background,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                context.l10n.showingPlotsCount(state.filteredPlots.length, allCount),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // ── Plot List / Grid ──────────────────────────────────────────────
          Expanded(
            child: state.isLoading
                ? GridView.builder(
                    padding: AppSpacing.allMd,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      mainAxisExtent: 220,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, _) => const PlotCardSkeleton(),
                  )
                : state.isError
                ? ErrorState(
                    title: context.l10n.unableToLoadPlots,
                    onRetry: () => logic.loadPlots(projectId),
                  )
                : state.filteredPlots.isEmpty
                ? EmptyState(
                    icon: Icons.landscape_outlined,
                    title: loc.noPlotsFound,
                    message: state.searchQuery.isNotEmpty
                        ? context.l10n.noPlotsMatch(state.searchQuery)
                        : context.l10n.noPlotsFilter,
                  )
                : RefreshIndicator(
                    onRefresh: () => logic.loadPlots(projectId),
                    child: isTablet || isDesktop
                        ? GridView.builder(
                            padding: AppSpacing.allLg,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 3 : 2,
                                  mainAxisSpacing: AppSpacing.lg,
                                  crossAxisSpacing: AppSpacing.lg,
                                  mainAxisExtent: 220,
                                ),
                            itemCount: state.filteredPlots.length,
                            itemBuilder: (context, index) {
                              final plot = state.filteredPlots[index];
                              return PlotCard(
                                plot: plot,
                                onTap: () => context.push(
                                  '/project/$projectId/plots/${plot.id}',
                                ),
                              );
                            },
                          )
                        : ListView.separated(
                            padding: AppSpacing.allLg,
                            itemCount: state.filteredPlots.length,
                            separatorBuilder: (_, _) => AppSpacing.hMd,
                            itemBuilder: (context, index) {
                              final plot = state.filteredPlots[index];
                              return PlotCard(
                                plot: plot,
                                onTap: () => context.push(
                                  '/project/$projectId/plots/${plot.id}',
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color color;
  final VoidCallback onSelected;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : AppTheme.transparent,
          borderRadius: AppRadius.circularPill,
          border: Border.all(color: isSelected ? color : AppTheme.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            AppSpacing.wXs,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.white.withValues(alpha: 0.25)
                    : color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? AppTheme.white : color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
