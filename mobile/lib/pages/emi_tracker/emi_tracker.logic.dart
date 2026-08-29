import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:customer_app/services/auth_service.dart';
import 'package:customer_app/services/api_service.dart';
import 'dart:async';
import 'emi_tracker.state.dart';

part 'emi_tracker.logic.g.dart';

@riverpod
class EmiTrackerLogic extends _$EmiTrackerLogic {
  StreamSubscription? _paymentsSubscription;

  @override
  EmiTrackerState build(String plotId) {
    _loadPlotDetails(plotId);
    _listenToPayments(plotId);

    ref.onDispose(() {
      _paymentsSubscription?.cancel();
    });

    return const EmiTrackerState(isLoading: true);
  }

  Future<void> _loadPlotDetails(String plotId) async {
    try {
      final data = await ApiService.getAssignPlotDetails(plotId);
      if (data != null) {
        state = state.copyWith(
          totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
          paidAmount: (data['paidAmount'] ?? 0.0).toDouble(),
        );
      } else {
        state = state.copyWith(errorMessage: 'Failed to load property details');
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load property details');
    }
  }

  void _listenToPayments(String plotId) {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'User not logged in',
      );
      return;
    }

    _paymentsSubscription = ApiService.watchPlotPayments(plotId, uid)
        .listen(
          (payments) {
            state = state.copyWith(isLoading: false, payments: payments);
          },
          onError: (error) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: 'Failed to load payments',
            );
          },
        );
  }
}
