import 'package:customer_app/utils/snackbar_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import '../../../main.dart';
import '../../../l10n/app_localizations.dart';
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

  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    if (email.isEmpty || password.isEmpty) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);
    final userCredential = await AuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential == null) {
      state = state.copyWith(isLoading: false);
      return false;
    }

    // Check if email is verified
    if (userCredential.user != null && !userCredential.user!.emailVerified) {
      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Consumer(
            builder: (context, ref, _) {
              final loc = AppLocalizations.of(context);
              final dialogState = ref.watch(loginLogicProvider);
              return AlertDialog(
                title: Text(loc.emailVerificationRequiredTitle),
                content: Text(loc.emailVerificationRequiredMessage),
                actions: [
                  TextButton(
                    onPressed: () {
                      clearUnverifiedUser();
                      Navigator.of(ctx).pop();
                    },
                    child: Text(loc.cancel),
                  ),
                  FilledButton.icon(
                    onPressed: dialogState.isResendingMail
                        ? null
                        : () async {
                            final success = await ref
                                .read(loginLogicProvider.notifier)
                                .resendVerificationEmail(
                                  userCredential.user!,
                                  context,
                                );
                            if (success && ctx.mounted) {
                              Navigator.of(ctx).pop();
                            }
                          },
                    icon: dialogState.isResendingMail
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.mail_outline, size: 18),
                    label: Text(loc.sendVerificationMail),
                  ),
                ],
              );
            },
          ),
        );
      }
      return false;
    }

    // Check status in Firestore
    if (userCredential.user != null) {
      final data = await ApiService.getUserProfile(userCredential.user!.uid);
      final tokenResult = await userCredential.user!.getIdTokenResult(true);
      if (tokenResult.token != null) {
        final tokenData = {
          'token': tokenResult.token,
          'expirationTime': tokenResult.expirationTime?.toIso8601String(),
          'authTime': tokenResult.authTime?.toIso8601String(),
          'issuedAtTime': tokenResult.issuedAtTime?.toIso8601String(),
          'signInProvider': tokenResult.signInProvider,
          'claims': tokenResult.claims,
        };
        debugPrint('Token Result Data: $tokenData');
        await appBox.put('authToken', tokenResult.token);
        await appBox.put('authTokenResult', jsonEncode(tokenData));
      }

      if (data != null) {
        final status = data['status'];
        final loc = (context.mounted) ? AppLocalizations.of(context) : null;

        if (status == 'BLOCKED') {
          await AuthService.signOut();
          state = state.copyWith(
            isLoading: false,
            errorMessage:
                loc?.accountBlocked ??
                'Your account has been blocked by an administrator.',
          );
          return false;
        } else if (status == 'DELETED') {
          await AuthService.signOut();
          state = state.copyWith(
            isLoading: false,
            errorMessage:
                loc?.accountDeleted ?? 'This account has been deleted.',
          );
          return false;
        }

        // Save user data to local storage
        await appBox.put(
          'userData',
          jsonEncode(
            data,
            toEncodable: (dynamic item) {
              if (item is Timestamp) {
                return item.toDate().toIso8601String();
              }
              return item;
            },
          ),
        );
      }
    }

    state = state.copyWith(isLoading: false);
    return true;
  }

  Future<void> clearUnverifiedUser() async {
    await AuthService.signOut();
    state = state.copyWith(unverifiedUser: null);
  }

  Future<bool> resendVerificationEmail(User user, BuildContext context) async {
    state = state.copyWith(isResendingMail: true, errorMessage: null);
    final loc = AppLocalizations.of(context);

    try {
      await user.sendEmailVerification();
      await AuthService.signOut();

      AppSnackbar.showGlobalSuccess(loc.verificationEmailSentSuccessfully);

      state = state.copyWith(isResendingMail: false);

      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isResendingMail: false,
        errorMessage: FirebaseAuthErrorMapper.getMessage(e.code),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isResendingMail: false,
        errorMessage: FirebaseAuthErrorMapper.getMessage(e.toString()),
      );
      return false;
    }
  }
}
