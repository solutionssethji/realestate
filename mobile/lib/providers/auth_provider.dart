import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/customer.dart';final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

final customerProvider = StreamProvider<Customer?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.exists ? Customer.fromJson({'id': doc.id, ...doc.data()!}) : null);
});

final tokenRefreshProvider = StreamProvider<String?>((ref) {
  return FirebaseAuth.instance.idTokenChanges().asyncMap((user) async {
    if (user == null) return null;
    try {
      // Force refresh token if needed, or just get the current one
      final token = await user.getIdToken(true);
      return token;
    } catch (e) {
      return null;
    }
  });
});

