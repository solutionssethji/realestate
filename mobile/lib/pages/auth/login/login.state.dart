import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'login.state.freezed.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState({
    @Default(false) bool isLoading,
    @Default(true) bool isObscure,
    @Default(false) bool isResendingMail,
    User? unverifiedUser,
    String? errorMessage,
  }) = _LoginState;
}
