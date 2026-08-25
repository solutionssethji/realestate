import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please enter your email address.',
        isSent: false,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null, isSent: false);

    try {
      // 1. Check user in Firestore
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No account found with this email address.',
          isSent: false,
        );
        return false;
      }

      // 2. Check/send Firebase Auth reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: normalizedEmail,
      );

      state = state.copyWith(
        isLoading: false,
        isSent: true,
        errorMessage: null,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSent: false,
        errorMessage: switch (e.code) {
          'user-not-found' => 'No account found with this email address.',
          'invalid-email' => 'Please enter a valid email address.',
          'too-many-requests' => 'Too many requests. Please try again later.',
          _ => e.message ?? 'Failed to send reset link.',
        },
      );

      return false;
    } catch (e) {
      log('e=====> $e');
      state = state.copyWith(
        isLoading: false,
        isSent: false,
        errorMessage: 'An unexpected error occurred.',
      );

      return false;
    }
  }
}
