import 'package:freezed_annotation/freezed_annotation.dart';

part 'faq.state.freezed.dart';

@freezed
sealed class FaqState with _$FaqState {
  const factory FaqState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Map<String, dynamic>> faqs,
  }) = _FaqState;
}
