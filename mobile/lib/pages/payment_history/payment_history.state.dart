import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_history.state.freezed.dart';

@freezed
sealed class PaymentHistoryState with _$PaymentHistoryState {
  const factory PaymentHistoryState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Map<String, dynamic>> payments,
  }) = _PaymentHistoryState;
}
