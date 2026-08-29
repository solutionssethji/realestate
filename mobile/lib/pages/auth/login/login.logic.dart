import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import 'login.state.dart';

part 'login.logic.g.dart';

@riverpod
class LoginLogic extends _$LoginLogic {
  @override
  LoginState build() {
    return const LoginState();
  }

  void toggleObscure() {
    state = state.copyWith(isObscure: !state.isObscure);
  }

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userCredential = await AuthService.signInWithEmailAndPassword(
          email: email, password: password);

      // Check if email is verified
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await AuthService.signOut();
        state = state.copyWith(
          isLoading: false,
          unverifiedUser: userCredential.user,
        );
        return false;
      }

      // Check status in Firestore
      if (userCredential.user != null) {
        final data = await ApiService.getUserProfile(userCredential.user!.uid);

        if (data != null) {
          final status = data['status'];

          if (status == 'BLOCKED') {
            await AuthService.signOut();
            state = state.copyWith(
              isLoading: false,
              errorMessage:
                  'Your account has been blocked by an administrator.',
            );
            return false;
          } else if (status == 'DELETED') {
            await AuthService.signOut();
            state = state.copyWith(
              isLoading: false,
              errorMessage: 'This account has been deleted.',
            );
            return false;
          }
        }
      }

      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Login failed',
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

  void clearUnverifiedUser() {
    state = state.copyWith(unverifiedUser: null);
  }

  Future<bool> resendVerificationEmail() async {
    if (state.unverifiedUser == null) return false;

    state = state.copyWith(isResendingMail: true, errorMessage: null);
    try {
      await state.unverifiedUser!.sendEmailVerification();
      state = state.copyWith(isResendingMail: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isResendingMail: false,
        errorMessage: e.code == 'too-many-requests'
            ? 'Too many requests. Please wait a few minutes before trying again.'
            : e.message ?? 'Failed to send verification email.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isResendingMail: false,
        errorMessage: 'An unexpected error occurred.',
      );
      return false;
    }
  }
}
