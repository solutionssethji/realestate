import '../../../utils/app_dialogs.dart';
import 'package:customer_app/utils/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../routes/app_routes.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../main.dart';
import '../../../utils/l10n_extension.dart';
import 'otp.state.dart';

part 'otp.logic.g.dart';

@riverpod
class OtpLogic extends _$OtpLogic {
  @override
  OtpState build() {
    return const OtpState();
  }

  Future<void> verifyOtp(
    String verificationId,
    String smsCode,
    String phoneNumber,
    String countryCode,
    BuildContext context,
  ) async {
    final l10n = context.l10n;
    if (smsCode.length != 6) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await AuthService.signInWithCredential(credential);

      if (userCredential?.user != null) {
        final uid = userCredential!.user!.uid;

        // Save auth token dummy for routing bypass if needed
        await appBox.put('authToken', uid);

        // Check if user profile exists in Firestore
        final profile = await ApiService.getUserProfile(uid);

        if (profile != null) {
          final status = profile['status'] as String?;
          if (status == 'DISABLED' || status == 'BLOCKED') {
            await AuthService.signOut();
            state = state.copyWith(
              isLoading: false,
              errorMessage: l10n.authErrUserDisabled,
            );
            if (context.mounted) {
              AppDialogs.showErrorDialog(context, l10n.authErrUserDisabled);
            }
            return;
          } else if (status == 'DELETED') {
            await AuthService.signOut();
            state = state.copyWith(
              isLoading: false,
              errorMessage: l10n.authErrUserDeleted,
            );
            if (context.mounted) {
              AppDialogs.showErrorDialog(context, l10n.authErrUserDeleted);
            }
            return;
          }

          // Profile exists and not blocked, direct login
          await appBox.put('isProfileComplete', true);
          if (context.mounted) {
            context.go(AppRoutes.home);
          }
        } else {
          // Profile missing, navigate to register
          await appBox.put('isProfileComplete', false);
          await appBox.put('userPhoneNumber', phoneNumber);
          await appBox.put('userCountryCode', countryCode);
          if (context.mounted) {
            context.go(
              AppRoutes.register,
              extra: {'phoneNumber': phoneNumber, 'countryCode': countryCode},
            );
          }
        }
      } else {
        state = state.copyWith(isLoading: false, errorMessage: l10n.invalidOtp);
        if (context.mounted) {
          AppSnackbar.showError(context, l10n.invalidOtp);
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: l10n.failedToVerifyOtp,
      );
      if (context.mounted) {
        AppSnackbar.showError(context, l10n.failedToVerifyOtp);
      }
    }
  }

  Future<void> resendOtp(
    String completeNumber,
    String phoneNumber,
    String countryCode,
    BuildContext context,
  ) async {
    final l10n = context.l10n;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final status = await ApiService.checkUserStatusByPhone(phoneNumber, countryCode);
      if (status == 'DISABLED' || status == 'BLOCKED') {
        state = state.copyWith(
          isLoading: false,
          errorMessage: l10n.authErrUserDisabled,
        );
        if (context.mounted) {
          AppDialogs.showErrorDialog(context, l10n.authErrUserDisabled);
        }
        return;
      } else if (status == 'DELETED') {
        state = state.copyWith(
          isLoading: false,
          errorMessage: l10n.authErrUserDeleted,
        );
        if (context.mounted) {
          AppDialogs.showErrorDialog(context, l10n.authErrUserDeleted);
        }
        return;
      }

      await AuthService.verifyPhoneNumber(
        phoneNumber: completeNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: e.message ?? l10n.verificationFailed,
          );
          if (context.mounted) {
            AppSnackbar.showError(
              context,
              e.message ?? l10n.verificationFailed,
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(isLoading: false);
          if (context.mounted) {
            AppSnackbar.showSuccess(context, l10n.otpResentSuccessfully);
            context.pushReplacement(
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
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: l10n.failedToResendOtp,
      );
      if (context.mounted) {
        AppSnackbar.showError(context, l10n.failedToResendOtp);
      }
    }
  }

}