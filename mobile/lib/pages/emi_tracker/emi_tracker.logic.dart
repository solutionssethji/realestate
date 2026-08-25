import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      final doc = await FirebaseFirestore.instance
          .collection('assignPlots')
          .doc(plotId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'User not logged in',
      );
      return;
    }

    _paymentsSubscription = FirebaseFirestore.instance
        .collection('payments')
        .where('bookingId', isEqualTo: plotId)
        .where('zId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final payments = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();
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
