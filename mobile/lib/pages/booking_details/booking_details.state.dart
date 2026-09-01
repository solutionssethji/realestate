import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_details.state.freezed.dart';

@freezed
sealed class BookingDetailsState with _$BookingDetailsState {
  const factory BookingDetailsState({
    @Default(true) bool isLoading,
    @Default(0.0) double totalAmount,
    @Default(0.0) double paidAmount,
    @Default([]) List<Map<String, dynamic>> payments,
    Map<String, dynamic>? bookingData,
    String? errorMessage,
  }) = _BookingDetailsState;

  const BookingDetailsState._();

  double get balance => totalAmount - paidAmount;
}
