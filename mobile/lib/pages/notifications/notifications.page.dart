import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import 'package:customer_app/theme/theme.dart';
import 'package:customer_app/widgets/shimmer_loader.dart';
import 'package:customer_app/routes/app_routes.dart';
import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:customer_app/widgets/empty_state.dart';
import 'package:customer_app/widgets/error_state.dart';
import 'package:customer_app/widgets/skeleton_list.dart';
import 'package:customer_app/widgets/app_loading_view.dart';
import 'package:customer_app/theme/spacing.dart';
import 'package:customer_app/widgets/offer_card.dart';
import 'package:customer_app/models/app_notification.dart';
import 'notifications.logic.dart';

class NotificationsPage extends HookConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(notificationsLogicProvider);
    final logic = ref.read(notificationsLogicProvider.notifier);

    void handleNotificationTap(AppNotification notification) async {
      await logic.markAsRead(notification);

      // Route based on type
      if (context.mounted) {
        final resourceId = notification.resourceId ?? notification.payload?['offerId'];
        if (notification.type == 'NEW_OFFER' && resourceId != null) {
          context.push(AppRoutes.offerDetails(resourceId));
        } else if (notification.type == 'OFFER' && resourceId != null) {
          context.push(AppRoutes.offerDetails(resourceId));
        }
      }
    }

    return Scaffold(
      appBar: PremiumAppBar(title: loc.notification),
      body: SafeArea(
        child: state.isLoading
            ? SkeletonList(
                itemCount: 5,
                itemBuilder: (_, _) => const NotificationListTileSkeleton(),
              )
            : state.isError
                ? ErrorState(
                    title: state.errorMessage ?? loc.somethingWentWrong,
                    onRetry: logic.loadNotifications,
                  )
                : state.notifications.isEmpty
                    ? EmptyState(
                        icon: Icons.notifications_none,
                        title: loc.noAlerts,
                        message: '',
                      )
                    : RefreshIndicator(
                        onRefresh: () => logic.loadNotifications(isRefresh: true),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                              Future.microtask(() {
                                logic.loadMore();
                              });
                            }
                            return false;
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: state.notifications.length +
                                (state.isFetchingMore ? 1 : 0),
                            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                            itemBuilder: (context, index) {
                              if (index == state.notifications.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(AppSpacing.md),
                                    child: AppLoadingView(size: 24),
                                  ),
                                );
                              }
                              final item = state.notifications[index];
                    final isRead = item.read;
                    
                    if (item.offer != null) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            OfferCard(
                              offer: item.offer!,
                              onTap: () => handleNotificationTap(item),
                            ),
                            if (!isRead)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: AppTheme.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                    
                    return Card(
                      color: isRead ? Colors.white : AppTheme.midnightNavy.withValues(alpha: 0.05),
                      margin: const EdgeInsets.only(bottom: 12.0),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isRead ? Colors.grey.shade200 : AppTheme.midnightNavy.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ListTile(
                        onTap: () => handleNotificationTap(item),
                        title: Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            item.body,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        trailing: isRead
                            ? null
                            : Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppTheme.midnightNavy,
                                  shape: BoxShape.circle,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
      ),
    );
  }
}
