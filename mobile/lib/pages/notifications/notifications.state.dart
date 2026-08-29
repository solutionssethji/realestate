import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsState {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;
  final bool hasLoaded;
  final bool hasMore;
  final bool isFetchingMore;
  final bool isError;
  final String? errorMessage;
  final DocumentSnapshot? lastDocument;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = true,
    this.hasLoaded = false,
    this.hasMore = true,
    this.isFetchingMore = false,
    this.isError = false,
    this.errorMessage,
    this.lastDocument,
  });

  NotificationsState copyWith({
    List<Map<String, dynamic>>? notifications,
    bool? isLoading,
    bool? hasLoaded,
    bool? hasMore,
    bool? isFetchingMore,
    bool? isError,
    String? errorMessage,
    DocumentSnapshot? lastDocument,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}
