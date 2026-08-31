import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:customer_app/services/auth_service.dart';
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
}
