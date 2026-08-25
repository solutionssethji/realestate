import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password.state.freezed.dart';

@freezed
sealed class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState({
    @Default(false) bool isLoading,
    @Default(false) bool isSent,
    String? errorMessage,
  }) = _ForgotPasswordState;
}
