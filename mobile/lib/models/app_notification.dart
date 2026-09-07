import 'package:freezed_annotation/freezed_annotation.dart';
import 'offer.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String title,
    required String body,
    required String type,
    @Default(false) bool read,
    String? resourceId,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: false, includeToJson: false) Offer? offer,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
