import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.state.freezed.dart';

@freezed
sealed class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _ProfileState;
}
