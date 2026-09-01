import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'change_password.state.dart';

part 'change_password.logic.g.dart';

@riverpod
class ChangePasswordLogic extends _$ChangePasswordLogic {
  @override
  ChangePasswordState build() {
    return const ChangePasswordState();
  }

  void toggleCurrentPasswordObscure() {
    state = state.copyWith(isCurrentPasswordObscure: !state.isCurrentPasswordObscure);
  }

  void toggleNewPasswordObscure() {
    state = state.copyWith(isNewPasswordObscure: !state.isNewPasswordObscure);
  }

  void toggleConfirmPasswordObscure() {
    state = state.copyWith(isConfirmPasswordObscure: !state.isConfirmPasswordObscure);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User not found. Please log in again.',
        );
        return false;
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to change password';
      if (e.code == 'wrong-password') {
        msg = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        msg = 'New password is too weak';
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
