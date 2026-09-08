import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:customer_app/services/auth_service.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile.state.dart';

part 'profile.logic.g.dart';

@riverpod
class ProfileLogic extends _$ProfileLogic {
  @override
  ProfileState build() {
    return const ProfileState();
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await AuthService.signOut();
    state = state.copyWith(isLoading: false);
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final uid = AuthService.currentUser?.uid;
      if (uid == null) {
        state = state.copyWith(isLoading: false);
        return false;
      }

      // Check if user has active bookings
      final properties = await ApiService.fetchUserPropertiesPagination(
        limit: 1,
        uid: uid,
      );
      if (properties.data.isNotEmpty) {
        // Return false and let UI handle showing the localized string
        state = state.copyWith(isLoading: false);
        return false;
      }

      // Delete the user's Firestore document
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      await AuthService.currentUser?.delete();
      await AuthService.signOut();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
