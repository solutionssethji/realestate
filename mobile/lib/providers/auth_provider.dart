import 'package:firebase_auth/firebase_auth.dart';
import 'package:customer_app/services/auth_service.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/customer.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

final customerProvider = StreamProvider<Customer?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  return ApiService.watchUserProfile(user.uid)
      .map((data) => data != null ? Customer.fromJson(data) : null);
});

final tokenRefreshProvider = StreamProvider<String?>((ref) {
  return AuthService.idTokenChanges().asyncMap((user) async {
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

