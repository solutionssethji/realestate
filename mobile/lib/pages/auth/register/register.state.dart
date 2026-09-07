import 'package:freezed_annotation/freezed_annotation.dart';

part 'register.state.freezed.dart';

@freezed
sealed class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _RegisterState;
}
