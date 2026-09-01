import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_site_visits.state.freezed.dart';

@freezed
sealed class MySiteVisitsState with _$MySiteVisitsState {
  const factory MySiteVisitsState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Map<String, dynamic>> visits,
  }) = _MySiteVisitsState;
}
