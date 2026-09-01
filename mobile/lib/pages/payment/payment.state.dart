import 'package:freezed_annotation/freezed_annotation.dart';
import '../../models/payment_intent.dart';

part 'payment.state.freezed.dart';

@freezed
abstract class PaymentState with _$PaymentState {
  const factory PaymentState({
    @Default(false) bool isLoading,
    @Default(PaymentStatus.pending) PaymentStatus status,
    PaymentIntent? currentIntent,
    String? errorMessage,
  }) = _PaymentState;
}
