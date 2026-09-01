import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_password.state.freezed.dart';

@freezed
abstract class ChangePasswordState with _$ChangePasswordState {
  const factory ChangePasswordState({
    @Default(false) bool isLoading,
    @Default(true) bool isCurrentPasswordObscure,
    @Default(true) bool isNewPasswordObscure,
    @Default(true) bool isConfirmPasswordObscure,
    String? errorMessage,
  }) = _ChangePasswordState;
}
