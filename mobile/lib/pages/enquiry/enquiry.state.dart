import 'package:freezed_annotation/freezed_annotation.dart';

part 'enquiry.state.freezed.dart';

@freezed
sealed class EnquiryState with _$EnquiryState {
  const factory EnquiryState({
    @Default(false) bool isSubmitting,
    @Default(false) bool isSuccess,
    @Default(false) bool isError,
    String? errorMessage,
  }) = _EnquiryState;
}
