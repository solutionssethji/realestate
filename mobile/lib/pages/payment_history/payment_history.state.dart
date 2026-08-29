import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'payment_history.state.freezed.dart';

@freezed
class PaymentHistoryState with _$PaymentHistoryState {
  const factory PaymentHistoryState({
    @Default(true) bool isLoading,
    @Default(false) bool hasLoaded,
    @Default(true) bool hasMore,
    @Default(false) bool isFetchingMore,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Map<String, dynamic>> payments,
    DocumentSnapshot? lastDocument,
  }) = _PaymentHistoryState;
}
