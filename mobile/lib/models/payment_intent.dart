import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_intent.freezed.dart';

enum PaymentStatus { pending, processing, success, failed, cancelled }

@freezed
class PaymentIntent with _$PaymentIntent {
  const factory PaymentIntent({
    required String id,
    required double amount,
    required String currency,
    required String referenceId,
    required String description,
    @Default(PaymentStatus.pending) PaymentStatus status,
    String? transactionId,
    String? errorMessage,
  }) = _PaymentIntent;
}
