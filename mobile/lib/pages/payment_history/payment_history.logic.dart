import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_history.state.dart';

part 'payment_history.logic.g.dart';

@riverpod
class PaymentHistoryLogic extends _$PaymentHistoryLogic {
  @override
  PaymentHistoryState build() {
    Future.microtask(() => loadPayments());
    return const PaymentHistoryState();
  }

  Future<void> loadPayments() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Unauthenticated');

      final result = await FirebaseFunctions.instance
          .httpsCallable('getCustomerPayments')
          .call();
      final data = result.data as Map;

      if (data['success'] == true && data['payments'] != null) {
        state = state.copyWith(
          payments: List<Map<String, dynamic>>.from(data['payments']),
          isLoading: false,
        );
      } else {
         state = state.copyWith(
          payments: [],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
