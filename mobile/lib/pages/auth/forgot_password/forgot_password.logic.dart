import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import 'forgot_password.state.dart';

part 'forgot_password.logic.g.dart';

@riverpod
class ForgotPasswordLogic extends _$ForgotPasswordLogic {
  @override
  ForgotPasswordState build() {
    ref.keepAlive();
    return const ForgotPasswordState();
  }

  Future<bool> sendResetLink(String email) async {
    final enteredEmail = email.trim();
    final normalizedEmail = enteredEmail.toLowerCase();

    if (!_isValidEmail(normalizedEmail)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: FirebaseAuthErrorMapper.getForgotPasswordMessage(
          'invalid-email',
        ),
        isSent: false,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, isSent: false);

    // 1. Check user in Firestore
    var user = await ApiService.getUserByEmail(normalizedEmail);

    // Older accounts may have been saved with uppercase email characters.
    if (user == null && enteredEmail != normalizedEmail) {
      user = await ApiService.getUserByEmail(enteredEmail);
    }

    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: FirebaseAuthErrorMapper.getForgotPasswordMessage(
          'user-not-found',
        ),
        isSent: false,
      );
      return false;
    }

    // 2. Check/send Firebase Auth reset email
    await AuthService.sendPasswordResetEmail(email: normalizedEmail);

    state = state.copyWith(isLoading: false, isSent: true, errorMessage: null);

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }
}
