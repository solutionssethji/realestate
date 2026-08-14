import 'package:freezed_annotation/freezed_annotation.dart';

part 'site_visit.state.freezed.dart';

@freezed
sealed class SiteVisitState with _$SiteVisitState {
  const factory SiteVisitState({
    @Default(false) bool isSubmitting,
    @Default(false) bool isSuccess,
    @Default(false) bool isError,
    String? errorMessage,
  }) = _SiteVisitState;
}
