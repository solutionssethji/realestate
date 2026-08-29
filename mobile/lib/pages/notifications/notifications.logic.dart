import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:customer_app/services/auth_service.dart';
import '../../../services/api_service.dart';
import 'notifications.state.dart';

part 'notifications.logic.g.dart';

@riverpod
class NotificationsLogic extends _$NotificationsLogic {
  @override
  NotificationsState build() {
    Future.microtask(() => load(isRefresh: true));
    return const NotificationsState();
  }

  Future<void> load({bool isRefresh = false}) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      state = state.copyWith(isLoading: false, isError: true, errorMessage: 'User not logged in');
      return;
    }

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
        state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
      }
    }

    try {
      final response = await ApiService.fetchNotificationsPagination(
        userId: uid,
        lastDocument: state.lastDocument,
        limit: 15,
      );

      final combinedNotifications = isRefresh ? response.data : [...state.notifications, ...response.data];
      
      state = state.copyWith(
        notifications: combinedNotifications,
        lastDocument: response.lastDocument,
        hasMore: response.data.length == 15,
        isLoading: false,
        isFetchingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isFetchingMore || !state.hasMore) return;
    await load();
  }

  Future<void> markRead(Map<String, dynamic> notification) async {
    final userId = AuthService.currentUser?.uid;
    final notificationId = notification['id'];
    
    // Optimistic update
    final index = state.notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      final updatedList = List<Map<String, dynamic>>.from(state.notifications);
      updatedList[index] = {...updatedList[index], 'isRead': true};
      state = state.copyWith(notifications: updatedList);
    }

    if (userId != null && notificationId != null) {
      await ApiService.markNotificationRead(userId, notificationId);
    }
  }
}
