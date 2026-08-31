import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:customer_app/services/auth_service.dart';
import 'package:customer_app/services/api_service.dart';
import 'payment_history.state.dart';

part 'payment_history.logic.g.dart';

@riverpod
class PaymentHistoryLogic extends _$PaymentHistoryLogic {
  @override
  PaymentHistoryState build() {
    Future.microtask(() => load(isRefresh: true));
    return const PaymentHistoryState();
  }

  Future<void> load({bool isRefresh = false}) async {
    final user = AuthService.currentUser;
    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: 'User not logged in',
      );
      return;
    }

    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        lastDocument: null,
        payments: [],
        isError: false,
        errorMessage: null,
      );
    } else {
      if (!state.hasMore || state.isFetchingMore || state.isLoading) return;
      if (state.payments.isNotEmpty) {
        state = state.copyWith(isFetchingMore: true);
      } else {
        state = state.copyWith(
          isLoading: true,
          isError: false,
          errorMessage: null,
        );
      }
    }

    final response = await ApiService.fetchUserPaymentsPagination(
      uid: user.uid,
      lastDocument: state.lastDocument,
      limit: 15,
    );

    final combinedPayments = isRefresh
        ? response.data
        : [...state.payments, ...response.data];

    state = state.copyWith(
      payments: combinedPayments,
      lastDocument: response.lastDocument,
      hasMore: response.data.length == 15,
      isLoading: false,
      isFetchingMore: false,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isFetchingMore || !state.hasMore) return;
    await load();
  }
}
