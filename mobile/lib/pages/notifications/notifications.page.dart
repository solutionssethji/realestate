import 'package:customer_app/widgets/premium_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../services/api_service.dart';
import '../../../utils/l10n_extension.dart';
import '../../widgets/error_state.dart';
import '../../widgets/shimmer_loader.dart';

class NotificationsPage extends HookConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = useState<List<Map<String, dynamic>>>([]);
    final isLoading = useState(true);
    final errorMessage = useState<String?>(null);

    Future<void> loadNotifications() async {
      isLoading.value = true;
      errorMessage.value = null;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        isLoading.value = false;
        return;
      }
      try {
        notifications.value = await ApiService.getNotifications(uid);
      } catch (e) {
        errorMessage.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    useEffect(() {
      loadNotifications();
      return null;
    }, const []);

    return Scaffold(
      appBar: PremiumAppBar(title: context.l10n.alerts),
      body: isLoading.value
          ? ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, __) => const NotificationListTileSkeleton(),
            )
          : errorMessage.value != null
          ? ErrorState(message: errorMessage.value, onRetry: loadNotifications)
          : notifications.value.isEmpty
          ? Center(child: Text(context.l10n.noAlerts))
          : ListView.builder(
              itemCount: notifications.value.length,
              itemBuilder: (context, index) {
                final notification = notifications.value[index];
                return ListTile(
                  title: Text(
                    notification['title'] ?? context.l10n.notification,
                  ),
                  subtitle: Text(notification['body'] ?? ''),
                  trailing: const Icon(Icons.notifications),
                  onTap: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    final id = notification['id'];
                    if (uid != null && id != null) {
                      await ApiService.markNotificationRead(uid, id);
                      final updated = [...notifications.value];
                      updated[index] = {...updated[index], 'isRead': true};
                      notifications.value = updated;
                    }
                  },
                );
              },
            ),
    );
  }
}
