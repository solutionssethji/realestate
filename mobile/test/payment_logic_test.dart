import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:customer_app/pages/payment/payment.logic.dart';
import 'package:customer_app/models/payment_intent.dart';
import 'package:customer_app/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PaymentLogic Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      ApiService.mockSubmitPayment = (data) async {
        await Future.delayed(
          const Duration(milliseconds: 10),
        ); // simulate network
        final amount = data['amount'];

        if (amount == 1234.0) {
          return {
            'status': 'error',
            'message':
                'Payment declined by the bank. Please try another method.',
          };
        }
        if (amount == 9999.0) {
          return {
            'status': 'cancelled',
            'message': 'Payment was cancelled by the user.',
          };
        }

        return {
          'status': 'success',
          'data': {'transactionId': 'mock_txn_123'},
        };
      };
    });

    tearDown(() {
      container.dispose();
      ApiService.mockSubmitPayment = null;
    });

    test('Initial state is pending', () {
      final state = container.read(paymentLogicProvider);
      expect(state.isLoading, false);
      expect(state.status, PaymentStatus.pending);
      expect(state.errorMessage, null);
    });

    test('Successful payment flow', () async {
      final logic = container.read(paymentLogicProvider.notifier);
      container.listen(paymentLogicProvider, (_, __) {});

      final future = logic.initiatePayment(
        amount: 25000,
        referenceId: 'ref_123',
        description: 'Mock Payment',
      );

      // Check intermediate processing state
      expect(
        container.read(paymentLogicProvider).status,
        PaymentStatus.processing,
      );
      expect(container.read(paymentLogicProvider).isLoading, true);

      await future;

      // Check final success state
      final state = container.read(paymentLogicProvider);
      expect(state.isLoading, false);
      expect(state.status, PaymentStatus.success);
      expect(state.currentIntent?.transactionId, isNotNull);
    });

    test('Failed payment flow (mock value 1234.0)', () async {
      final logic = container.read(paymentLogicProvider.notifier);
      container.listen(paymentLogicProvider, (_, __) {});

      final future = logic.initiatePayment(
        amount: 1234.0,
        referenceId: 'ref_123',
        description: 'Mock Payment Failure',
      );

      await future;

      final state = container.read(paymentLogicProvider);
      expect(state.status, PaymentStatus.failed);
      expect(
        state.errorMessage,
        'Payment declined by the bank. Please try another method.',
      );
    });

    test('Cancelled payment flow (mock value 9999.0)', () async {
      final logic = container.read(paymentLogicProvider.notifier);
      container.listen(paymentLogicProvider, (_, __) {});

      final future = logic.initiatePayment(
        amount: 9999.0,
        referenceId: 'ref_123',
        description: 'Mock Payment Cancel',
      );

      await future;

      final state = container.read(paymentLogicProvider);
      expect(state.status, PaymentStatus.cancelled);
      expect(state.errorMessage, 'Payment was cancelled by the user.');
    });
  });
}
