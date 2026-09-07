import 'package:customer_app/utils/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../utils/l10n_extension.dart';
import 'login.state.dart';

part 'login.logic.g.dart';

@riverpod
class LoginLogic extends _$LoginLogic {
  @override
  LoginState build() {
    return const LoginState();
  }

  Future<void> sendOtp(
      String completeNumber, String phoneNumber, String countryCode, BuildContext context) async {
    final l10n = context.l10n;
    if (completeNumber.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await AuthService.verifyPhoneNumber(
        phoneNumber: completeNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (rare on iOS, sometimes on Android)
          // We can leave this empty or handle auto-login if needed
          // For now, let the user enter OTP manually
        },
        verificationFailed: (FirebaseAuthException e) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: e.message ?? l10n.verificationFailed,
          );
          if (context.mounted) {
            AppSnackbar.showError(context, e.message ?? l10n.verificationFailed);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(isLoading: false);
          if (context.mounted) {
            AppSnackbar.showSuccess(context, l10n.otpSentSuccessfully);
            context.push(
              AppRoutes.otp,
              extra: {
                'verificationId': verificationId,
                'phoneNumber': phoneNumber,
                'completeNumber': completeNumber,
                'countryCode': countryCode,
              },
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout handling
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: l10n.failedToSendOtp);
      if (context.mounted) {
        AppSnackbar.showError(context, l10n.failedToSendOtp);
      }
    }
  }
}
