import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:customer_app/services/auth_service.dart';
import 'package:customer_app/services/api_service.dart';
import 'dart:async';
import 'booking_details.state.dart';

part 'booking_details.logic.g.dart';

@riverpod
class BookingDetailsLogic extends _$BookingDetailsLogic {
  StreamSubscription? _paymentsSubscription;

  @override
  BookingDetailsState build(String id) {
    loadPlotDetails(id);
    listenToPayments(id);

    ref.onDispose(() {
      _paymentsSubscription?.cancel();
    });

    return const BookingDetailsState(isLoading: true);
  }

  Future<void> loadPlotDetails(String id) async {
    try {
      final data = await ApiService.getAssignPlotDetails(id);
      if (data != null) {
        state = state.copyWith(
          isLoading: false, // ← shimmer band karo jab data aa jaye
          bookingData: data,
          totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
          paidAmount: (data['paidAmount'] ?? 0.0).toDouble(),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load property details',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load property details: $e',
      );
    }
  }

  void listenToPayments(String plotId) {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'User not logged in',
      );
      return;
    }

    _paymentsSubscription = ApiService.watchPlotPayments(plotId, uid).listen(
      (payments) {
        // Only update payments — don't touch isLoading here
        state = state.copyWith(payments: payments);
      },
      onError: (error) {
        state = state.copyWith(errorMessage: 'Failed to load payments');
      },
    );
  }
}
