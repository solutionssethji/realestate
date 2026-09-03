import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../models/app_notification.dart';

part 'notifications.state.freezed.dart';

@freezed
sealed class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default(true) bool isLoading,
    @Default(false) bool isFetchingMore,
    @Default(false) bool isError,
    @Default(true) bool hasMore,
    dynamic lastDocument,
    @Default([]) List<AppNotification> notifications,
    String? errorMessage,
  }) = _NotificationsState;
}
