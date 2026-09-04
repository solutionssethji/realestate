import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'notifications.state.dart';
import '../../../services/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/app_notification.dart';

part 'notifications.logic.g.dart';

@riverpod
class NotificationsLogic extends _$NotificationsLogic {
  @override
  NotificationsState build() {
    Future.microtask(() => loadNotifications(isRefresh: true));
    return const NotificationsState();
  }

  Future<void> loadNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        lastDocument: null,
        notifications: [],
        isError: false,
        errorMessage: null,
      );
    } else {
      if (!state.hasMore || state.isFetchingMore || state.isLoading) return;
      if (state.notifications.isNotEmpty) {
        state = state.copyWith(isFetchingMore: true);
      } else {
        state = state.copyWith(
          isLoading: true,
          isError: false,
          errorMessage: null,
        );
      }
    }
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        isError: true,
        errorMessage: 'User not logged in',
      );
      return;
    }

    try {
      final (data, newLastDoc) = await ApiService.getNotifications(
        user.uid,
        lastDocument: state.lastDocument,
        limit: 20,
      );

      // Enrich notifications with offer data if applicable
      final enrichedData = await Future.wait(
        data.map((notification) async {
          if (notification.type == 'NEW_OFFER' ||
              notification.type == 'OFFER') {
            final resourceId = notification.resourceId;
            if (resourceId != null) {
              try {
                final offer = await ApiService.getOffer(resourceId);
                if (offer != null) {
                  return notification.copyWith(offer: offer);
                }
              } catch (e) {
                debugPrint('Failed to load offer for notification: $e');
              }
            }
          }
          return notification;
        }),
      );

      final unreadIds = enrichedData
          .where((n) => n.read != true)
          .map((n) => n.id)
          .toList();
      if (unreadIds.isNotEmpty) {
        // Update in background
        Future.wait(
          unreadIds.map((id) => ApiService.markNotificationRead(user.uid, id)),
        ).catchError((_) => []);
      }

      final readData = enrichedData.map((n) => n.copyWith(read: true)).toList();

      state = state.copyWith(
        notifications: isRefresh
            ? readData
            : [...state.notifications, ...readData],
        isLoading: false,
        isFetchingMore: false,
        lastDocument: newLastDoc,
        hasMore: data.length == 20,
      );
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isFetchingMore) return;
    await loadNotifications();
  }

  Future<void> markAsRead(AppNotification notification) async {
    final user = ref.read(currentUserProvider);
    if (user == null || notification.read == true) return;

    try {
      await ApiService.markNotificationRead(user.uid, notification.id);
      // Optimistically update state
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == notification.id) {
          return n.copyWith(read: true);
        }
        return n;
      }).toList();
      state = state.copyWith(notifications: updatedNotifications);
    } catch (e) {
      debugPrint('Error marking read: $e');
    }
  }
}
