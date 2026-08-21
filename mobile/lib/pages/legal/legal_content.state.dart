import 'package:freezed_annotation/freezed_annotation.dart';

part 'legal_content.state.freezed.dart';

@freezed
sealed class LegalContentState with _$LegalContentState {
  const factory LegalContentState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    String? content,
  }) = _LegalContentState;
}
