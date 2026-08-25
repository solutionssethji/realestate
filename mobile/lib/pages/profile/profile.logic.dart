import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    try {
      await FirebaseAuth.instance.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to logout',
      );
    }
  }
}
