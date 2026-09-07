import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp.state.freezed.dart';

@freezed
sealed class OtpState with _$OtpState {
  const factory OtpState({
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _OtpState;
}
