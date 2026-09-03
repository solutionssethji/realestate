import 'package:freezed_annotation/freezed_annotation.dart';
part 'referred_users.state.freezed.dart';

@freezed
sealed class ReferredUsersState with _$ReferredUsersState {
  const factory ReferredUsersState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Map<String, dynamic>> users,
    @Default(false) bool isFetchingMore,
    @Default(true) bool hasMore,
    @Default(0) int page,
  }) = _ReferredUsersState;
}
