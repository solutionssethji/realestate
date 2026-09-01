import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'payment.state.dart';
import '../../models/payment_intent.dart';
import '../../services/api_service.dart';
import '../../constants.dart';

part 'payment.logic.g.dart';

@riverpod
class PaymentLogic extends _$PaymentLogic {
  late Razorpay _razorpay;

  @override
  PaymentState build() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    ref.onDispose(() {
      _razorpay.clear();
    });

    return const PaymentState();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = state.currentIntent?.id;
    if (paymentId == null) return;

    // Server-side verification via Cloud Function
    final result = await FirebaseFunctions.instance
        .httpsCallable('verifyPayment')
        .call({
          'paymentId': paymentId,
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
          'status': 'SUCCESS',
        });

    final finalStatus = result.data['status'];

    if (finalStatus == 'SUCCESS') {
      state = state.copyWith(
        isLoading: false,
        status: PaymentStatus.success,
        currentIntent: state.currentIntent?.copyWith(
          status: PaymentStatus.success,
          transactionId: response.paymentId,
        ),
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        status: PaymentStatus.failed,
        errorMessage: 'Payment signature verification failed.',
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    state = state.copyWith(
      isLoading: false,
      status: PaymentStatus.failed,
      errorMessage: response.message ?? 'Payment failed or cancelled.',
      currentIntent: state.currentIntent?.copyWith(
        status: PaymentStatus.failed,
      ),
    );

    // Also notify backend of failure if we have a payment ID
    final paymentId = state.currentIntent?.id;
    if (paymentId != null) {
      FirebaseFunctions.instance
          .httpsCallable('verifyPayment')
          .call({'paymentId': paymentId, 'status': 'FAILED'})
          .then((_) {}, onError: (_) {}); // Ignore fire-and-forget error
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    state = state.copyWith(
      isLoading: false,
      status: PaymentStatus.failed,
      errorMessage: 'External wallets are not supported at this time.',
    );
  }

  /// Initiates a payment via a secure Cloud Function.
  Future<void> initiatePayment({
    required double amount,
    required String referenceId,
    required String description,
  }) async {
    state = state.copyWith(
      isLoading: true,
      status: PaymentStatus.processing,
      errorMessage: null,
      currentIntent: PaymentIntent(
        id: '', // Will be updated
        amount: amount,
        currency: 'INR',
        referenceId: referenceId,
        description: description,
        status: PaymentStatus.processing,
      ),
    );

    // Call initiatePayment Cloud Function
    final result = await ApiService.submitPayment({
      'referenceId': referenceId,
      'amount': amount,
      'currency': 'INR',
      'description': description,
    });

    final orderId = result['orderId']?.toString();
    final paymentId = result['paymentId']?.toString();

    if (orderId == null || paymentId == null) {
      throw Exception('Invalid response from server.');
    }

    state = state.copyWith(
      currentIntent: state.currentIntent?.copyWith(id: paymentId),
    );

    // Launch Razorpay checkout
    var options = {
      'key': AppConstants.paymentPublicKey.isNotEmpty
          ? AppConstants.paymentPublicKey
          : 'rzp_test_mock',
      'amount': (amount * 100).toInt(),
      'name': 'Real Estate Platform',
      'order_id': orderId,
      'description': description,
      'prefill': {
        'contact': '', // To be filled from user profile if available
        'email': '',
      },
    };

    _razorpay.open(options);
  }

  void reset() => state = const PaymentState();
}
