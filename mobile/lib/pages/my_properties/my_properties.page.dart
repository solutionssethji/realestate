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
                      (_, _) => const Padding(
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

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: AppTheme.midnightNavy.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              context.push(AppRoutes.bookingDetails(plotId));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.midnightNavy
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.real_estate_agent_rounded,
                                          color: AppTheme.midnightNavy,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              projectName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppTheme.midnightNavy,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              context.l10n.plotNoLabel(
                                                plotNumber.toString(),
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: status == 'SOLD'
                                              ? AppTheme.success.withValues(
                                                  alpha: 0.1,
                                                )
                                              : AppTheme.info.withValues(
                                                  alpha: 0.1,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          status,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: status == 'SOLD'
                                                    ? AppTheme.success
                                                    : AppTheme.info,
                                                letterSpacing: 0.5,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(
                                    height: 1,
                                    color: AppTheme.border,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'View Payment Details',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: AppTheme.midnightNavy,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: AppTheme.midnightNavy,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
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
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }
}
