import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import 'forgot_password.state.dart';

part 'forgot_password.logic.g.dart';

@riverpod
class ForgotPasswordLogic extends _$ForgotPasswordLogic {
  @override
  ForgotPasswordState build() {
    return const ForgotPasswordState();
  }

  Future<bool> sendResetLink(String email) async {
    final enteredEmail = email.trim();
    final normalizedEmail = enteredEmail.toLowerCase();
    final emailMsg = FirebaseAuthErrorMapper.getForgotPasswordMessage(
      'invalid-email',
    );
    if (!_isValidEmail(normalizedEmail)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: emailMsg,
        isSent: false,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, isSent: false);

    // Check/send Firebase Auth reset email
    try {
      await AuthService.sendPasswordResetEmail(email: normalizedEmail);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: FirebaseAuthErrorMapper.getForgotPasswordMessage(
          'default',
        ),
        isSent: false,
      );
      return false;
    }

    state = state.copyWith(isLoading: false, isSent: true, errorMessage: null);

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }
}
