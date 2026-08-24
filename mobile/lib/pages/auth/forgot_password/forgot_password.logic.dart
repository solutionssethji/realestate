import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password.state.dart';

part 'forgot_password.logic.g.dart';

@riverpod
class ForgotPasswordLogic extends _$ForgotPasswordLogic {
  @override
  ForgotPasswordState build() {
    return const ForgotPasswordState();
  }

  Future<bool> sendResetLink(String email) async {
    if (email.isEmpty) return false;

    state = state.copyWith(isLoading: true, errorMessage: null, isSent: false);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      state = state.copyWith(isLoading: false, isSent: true);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Failed to send reset link',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred.',
      );
      return false;
    }
  }
}
