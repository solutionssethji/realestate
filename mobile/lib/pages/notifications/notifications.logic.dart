import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_service.dart';

import 'notifications.state.dart';

class NotificationsLogic {
  const NotificationsLogic();

  Future<NotificationsState> load(String? userId) async {
    if (userId == null) {
      return const NotificationsState(notifications: [], isLoading: false);
    }

    final notifications = await ApiService.getNotifications(userId);
    return NotificationsState(notifications: notifications, isLoading: false);
  }

  Future<void> markRead(Map<String, dynamic> notification) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final notificationId = notification['id'];
    if (userId != null && notificationId != null) {
      await ApiService.markNotificationRead(userId, notificationId);
    }
  }
}
