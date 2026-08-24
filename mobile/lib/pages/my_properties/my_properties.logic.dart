import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'my_properties.state.dart';

part 'my_properties.logic.g.dart';

@riverpod
class MyPropertiesLogic extends _$MyPropertiesLogic {
  StreamSubscription? _subscription;

  @override
  MyPropertiesState build() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _listenToProperties(user.uid);
    } else {
      state = const MyPropertiesState(
        isLoading: false,
        errorMessage: 'User not logged in',
      );
    }

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const MyPropertiesState(isLoading: true);
  }

  void _listenToProperties(String uid) {
    _subscription = FirebaseFirestore.instance
        .collection('assignPlots')
        .where('customerId', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            final properties = snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();
            state = state.copyWith(
              isLoading: false,
              properties: properties,
              errorMessage: null,
            );
          },
          onError: (error) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: 'Failed to load properties',
            );
          },
        );
  }
}
