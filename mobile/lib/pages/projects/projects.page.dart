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
import '../../widgets/error_state.dart';
import '../../widgets/app_loading_view.dart';
import '../../routes/app_routes.dart';

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
      appBar: PremiumAppBar(title: loc.allProjects, showBackButton: false),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!state.isLoading &&
              !state.isFetchingMore &&
              state.filteredProjects.isNotEmpty &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            Future.microtask(() {
              logic.loadMore();
            });
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () => logic.loadProjects(isRefresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (state.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppLoadingView(),
                )
              else if (state.isError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: ErrorState(
                      title: context.l10n.unableToLoadProjects,
                      onRetry: logic.loadProjects,
                    ),
                  ),
                )
              else if (state.filteredProjects.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: EmptyState(
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
                    ),
                  ),
                )
              else ...[
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
                                AppRoutes.projectDetails(project.id),
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
                                  AppRoutes.projectDetails(project.id),
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
                      child: AppLoadingView(size: 24),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
