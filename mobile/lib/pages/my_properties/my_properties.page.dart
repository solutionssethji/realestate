import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../utils/l10n_extension.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/error_state.dart';
import '../../theme/spacing.dart';
import '../../theme/theme.dart';
import '../../widgets/app_loading_view.dart';
import 'my_properties.logic.dart';
import '../../widgets/empty_state.dart';
import '../../routes/app_routes.dart';

class MyPropertiesPage extends HookConsumerWidget {
  const MyPropertiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myPropertiesLogicProvider);
    final logic = ref.read(myPropertiesLogicProvider.notifier);

    return Scaffold(
      appBar: PremiumAppBar(
        title: context.l10n.myProperties,
        showBackButton: false,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!state.isLoading &&
              !state.isFetchingMore &&
              state.properties.isNotEmpty &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            Future.microtask(() {
              logic.loadMore();
            });
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () => logic.load(isRefresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (state.isLoading)
                SliverPadding(
                  padding: AppSpacing.allMd,
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: PropertyListTileSkeleton(),
                      ),
                      childCount: 4,
                    ),
                  ),
                )
              else if (state.isError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: ErrorState(
                      message: state.errorMessage,
                      onRetry: () => logic.load(isRefresh: true),
                    ),
                  ),
                )
              else if (state.properties.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100.0),
                    child: EmptyState(
                      icon: Icons.bookmark_outline,
                      title: context.l10n.noPropertiesFound,
                      message: context.l10n.noPropertiesYet,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: AppSpacing.allMd,
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final property = state.properties[index];
                      final plotId = property['id'];
                      final projectName =
                          property['projectName'] ??
                          context.l10n.unknownProject;
                      final plotNumber =
                          property['plotNumber'] ?? context.l10n.unknownPlot;
                      final status =
                          property['status'] ?? context.l10n.statusUnknown;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const Icon(
                            Icons.bookmark,
                            size: 40,
                            color: AppTheme.info,
                          ),
                          title: Text(
                            projectName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                context.l10n.plotNoLabel(plotNumber.toString()),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: status == 'SOLD'
                                      ? AppTheme.success.withValues(alpha: 0.12)
                                      : AppTheme.info.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: status == 'SOLD'
                                            ? AppTheme.success
                                            : AppTheme.info,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            context.push(AppRoutes.emiTracker(plotId));
                          },
                        ),
                      );
                    }, childCount: state.properties.length),
                  ),
                ),
              if (state.isFetchingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: AppLoadingView(size: 24),
                  ),
                ),
              // Applied to all cases
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}
