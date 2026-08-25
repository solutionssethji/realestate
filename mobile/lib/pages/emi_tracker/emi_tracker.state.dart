import 'package:freezed_annotation/freezed_annotation.dart';

part 'emi_tracker.state.freezed.dart';

@freezed
sealed class EmiTrackerState with _$EmiTrackerState {
  const factory EmiTrackerState({
    @Default(true) bool isLoading,
    @Default(0.0) double totalAmount,
    @Default(0.0) double paidAmount,
    @Default([]) List<Map<String, dynamic>> payments,
    String? errorMessage,
  }) = _EmiTrackerState;

  const EmiTrackerState._();

  double get balance => totalAmount - paidAmount;
}
