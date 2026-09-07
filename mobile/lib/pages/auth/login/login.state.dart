import 'package:freezed_annotation/freezed_annotation.dart';

part 'login.state.freezed.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState({
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _LoginState;
}
