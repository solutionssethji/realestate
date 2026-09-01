import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../utils/l10n_extension.dart';
import '../../widgets/error_state.dart';
import '../../widgets/skeleton_list.dart';
import '../../widgets/shimmer_loader.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_loading_view.dart';
import 'notifications.logic.dart';

class NotificationsPage extends HookConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsLogicProvider);
    final logic = ref.read(notificationsLogicProvider.notifier);

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.alerts),
      body: state.isLoading
          ? SkeletonList(
              itemCount: 5,
              spacing: AppSpacing.sm,
              itemBuilder: (_, _) => const NotificationListTileSkeleton(),
            )
          : state.isError
          ? ErrorState(
              message: state.errorMessage,
              onRetry: () => logic.load(isRefresh: true),
            )
          : state.notifications.isEmpty
          ? Center(child: Text(context.l10n.noAlerts))
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!state.isLoading &&
                    !state.isFetchingMore &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
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
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final notification = state.notifications[index];
                        return ListTile(
                          title: Text(
                            notification['title'] ?? context.l10n.notification,
                          ),
                          subtitle: Text(notification['body'] ?? ''),
                          trailing: const Icon(Icons.notifications),
                          onTap: () => logic.markRead(notification),
                        );
                      }, childCount: state.notifications.length),
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
