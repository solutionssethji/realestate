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

    return Scaffold(
      appBar: PremiumAppBar(title: loc.plotAvailability),
      body: Column(
        children: [
          // ── Search + Filters ─────────────────────────────────────────────
          Container(
            color: Colors.white,
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
                        isSelected: state.selectedStatusFilter == null,
                        color: AppTheme.midnightNavy,
                        onSelected: () => logic.setStatusFilter(null),
                      ),
                      AppSpacing.wSm,
                      _StatusChip(
                        label: loc.available,
                        isSelected:
                            state.selectedStatusFilter == PlotStatus.available,
                        color: AppTheme.success,
                        onSelected: () =>
                            logic.setStatusFilter(PlotStatus.available),
                      ),
                      AppSpacing.wSm,
                      _StatusChip(
                        label: loc.hold,
                        isSelected:
                            state.selectedStatusFilter == PlotStatus.hold,
                        color: AppTheme.warning,
                        onSelected: () =>
                            logic.setStatusFilter(PlotStatus.hold),
                      ),
                      AppSpacing.wSm,
                      _StatusChip(
                        label: loc.booked,
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

          // ── Grid ─────────────────────────────────────────────────────────
          Expanded(
            child: state.isLoading
                ? GridView.builder(
                    padding: AppSpacing.allMd,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: isTablet ? 1.35 : 1.7,
                    ),
                    itemCount: 6,
                    itemBuilder: (_, __) => const PlotCardSkeleton(),
                  )
                : state.isError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.unableToLoadPlots,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        AppSpacing.hLg,
                        OutlinedButton.icon(
                          onPressed: () => logic.loadPlots(projectId),
                          icon: const Icon(Icons.refresh),
                          label: Text(loc.tryAgain),
                        ),
                      ],
                    ),
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
                    child: GridView.builder(
                      padding: AppSpacing.allLg,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                        mainAxisSpacing: AppSpacing.lg,
                        crossAxisSpacing: AppSpacing.lg,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: state.filteredPlots.length,
                      itemBuilder: (context, index) {
                        final plot = state.filteredPlots[index];
                        return PlotCard(
                          plot: plot,
                          onTap: () => context.push(
                            '/home/project/$projectId/plots/${plot.id}',
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
  final bool isSelected;
  final Color color;
  final VoidCallback onSelected;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    //     final loc = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: AppRadius.circularPill,
          border: Border.all(color: isSelected ? color : AppTheme.border),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
