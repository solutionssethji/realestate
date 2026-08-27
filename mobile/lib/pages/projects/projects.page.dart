import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'projects.logic.dart';
import '../../widgets/property_card.dart';
import '../../theme/spacing.dart';
import '../../widgets/empty_state.dart';

class ProjectsPage extends HookConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(projectsLogicProvider);
    final logic = ref.read(projectsLogicProvider.notifier);
    final bool isTablet = ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final bool isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      appBar: PremiumAppBar(title: loc.allProjects),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.isError
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.unableToLoadProjects,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppSpacing.hLg,
                    OutlinedButton.icon(
                      onPressed: logic.loadProjects,
                      icon: const Icon(Icons.refresh),
                      label: Text(loc.tryAgain),
                    ),
                  ],
                ),
              )
            : state.filteredProjects.isEmpty
            ? EmptyState(
                title: loc.noProjectsFound,
                message: state.searchQuery.isNotEmpty
                    ? context.l10n.noResultsFor(state.searchQuery)
                    : context.l10n.noProjectsAtMoment,
                buttonText: state.searchQuery.isNotEmpty
                    ? context.l10n.clearSearchFilters
                    : null,
                onAction: state.searchQuery.isNotEmpty
                    ? () => logic.updateSearch('')
                    : null,
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!state.isLoading &&
                      !state.isFetchingMore &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    logic.loadMore();
                  }
                  return false;
                },
                child: RefreshIndicator(
                  onRefresh: () => logic.loadProjects(isRefresh: true),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: AppSpacing.allLg,
                        sliver: isDesktop || isTablet
                            ? SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: isDesktop ? 3 : 2,
                                      mainAxisSpacing: AppSpacing.lg,
                                      crossAxisSpacing: AppSpacing.lg,
                                      childAspectRatio: isDesktop ? 1.0 : 0.85,
                                    ),
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final project = state.filteredProjects[index];
                                  return PropertyCard(
                                    project: project,
                                    onTap: () => context.push(
                                      '/home/project/${project.id}',
                                    ),
                                  );
                                }, childCount: state.filteredProjects.length),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final project = state.filteredProjects[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.lg,
                                    ),
                                    child: PropertyCard(
                                      project: project,
                                      onTap: () => context.push(
                                        '/home/project/${project.id}',
                                      ),
                                    ),
                                  );
                                }, childCount: state.filteredProjects.length),
                              ),
                      ),
                      if (state.isFetchingMore)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
