import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../utils/l10n_extension.dart';
import '../../widgets/skeleton_list.dart';
import '../../widgets/shimmer_loader.dart';
import '../../widgets/error_state.dart';
import '../../theme/spacing.dart';
import '../../theme/theme.dart';
import '../../widgets/app_loading_view.dart';
import 'my_properties.logic.dart';

class MyPropertiesPage extends HookConsumerWidget {
  const MyPropertiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myPropertiesLogicProvider);
    final logic = ref.read(myPropertiesLogicProvider.notifier);

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.myProperties),
      body: state.isLoading
          ? SkeletonList(
              padding: AppSpacing.allMd,
              spacing: AppSpacing.sm,
              itemCount: 4,
              itemBuilder: (_, __) => const PropertyListTileSkeleton(),
            )
          : state.isError
          ? ErrorState(message: state.errorMessage, onRetry: () => logic.load(isRefresh: true))
          : state.properties.isEmpty
          ? Center(child: Text(context.l10n.noPropertiesYet))
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
                onRefresh: () => logic.load(isRefresh: true),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: AppSpacing.allMd,
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final property = state.properties[index];
                            final plotId = property['id'];
                            final projectName = property['projectName'] ?? 'Unknown Project';
                            final plotNumber = property['plotNumber'] ?? 'Unknown Plot';
                            final status = property['status'] ?? 'Unknown';

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: const Icon(Icons.bookmark, size: 40, color: AppTheme.info),
                                title: Text(
                                  projectName,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(context.l10n.plotNoLabel(plotNumber.toString())),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: status == 'SOLD'
                                            ? AppTheme.success.withValues(alpha: 0.12)
                                            : AppTheme.info.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status,
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: status == 'SOLD' ? AppTheme.success : AppTheme.info,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  context.push('/my-properties/$plotId/emi-tracker');
                                },
                              ),
                            );
                          },
                          childCount: state.properties.length,
                        ),
                      ),
                    ),
                    if (state.isFetchingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: AppLoadingView(size: 24),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
