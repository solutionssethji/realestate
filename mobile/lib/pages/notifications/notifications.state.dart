class NotificationsState {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = true,
  });

  NotificationsState copyWith({
    List<Map<String, dynamic>>? notifications,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
