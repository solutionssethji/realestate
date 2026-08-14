import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/l10n_extension.dart';
import '../../widgets/premium_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'projects.logic.dart';
import '../../widgets/property_card.dart';
import '../../theme/spacing.dart';
import '../../widgets/empty_state.dart';

class ProjectsPage extends ConsumerWidget {
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
      body: state.isLoading
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
          : RefreshIndicator(
              onRefresh: logic.loadProjects,
              child: GridView.builder(
                padding: AppSpacing.allLg,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  childAspectRatio: isDesktop ? 1.0 : 0.85,
                ),
                itemCount: state.filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = state.filteredProjects[index];
                  return PropertyCard(
                    project: project,
                    onTap: () => context.push('/home/project/${project.id}'),
                  );
                },
              ),
            ),
    );
  }
}
