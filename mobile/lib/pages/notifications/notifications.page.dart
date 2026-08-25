import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final notifs = await ApiService.getNotifications(uid);
      setState(() {
        notifications = notifs;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : notifications.isEmpty
          ? const Center(child: Text('No alerts.'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return ListTile(
                  title: Text(notif['title'] ?? 'Notification'),
                  subtitle: Text(notif['body'] ?? ''),
                  trailing: const Icon(Icons.notifications),
                  onTap: () {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    if (uid != null) {
                      ApiService.markNotificationRead(uid, notif['id']);
                      setState(() {
                        notifications[index]['isRead'] = true;
                      });
                    }
                  },
                );
              },
            )
    );
  }
}
