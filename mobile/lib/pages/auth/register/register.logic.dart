import 'dart:io';
import 'package:customer_app/utils/l10n_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../main.dart';
import '../../../utils/snackbar_utils.dart';
import 'register.state.dart';

part 'register.logic.g.dart';

@riverpod
class RegisterLogic extends _$RegisterLogic {
  @override
  RegisterState build() {
    return const RegisterState();
  }

  Future<void> register({
    required String name,
    required String mobile,
    required String countryCode,
    required String email,
    String? referralCode,
    XFile? profileImage,
    required BuildContext context,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final l10n = context.l10n;

    // Validate referral code if provided
    String? referredByUid;
    if (referralCode != null && referralCode.isNotEmpty) {
      final referrer = await ApiService.getUserByReferralCode(referralCode);
      if (referrer == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: l10n.invalidReferralCode,
        );
        return;
      }
      referredByUid = referrer['id']?.toString();
    }

    final user = AuthService.currentUser;
    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: l10n.authLost,
      );
      return;
    }

    // Create user document in Firestore
    String photoURL = '';
    if (profileImage != null) {
      final downloadUrl = await StorageService.uploadProfileImage(
        uid: user.uid,
        file: File(profileImage.path),
      );
      if (downloadUrl != null) {
        photoURL = downloadUrl;
      }
    }

    try {
      await ApiService.createUserProfile(user.uid, {
        'id': user.uid,
        'fullName': name,
        'mobileNumber': mobile,
        'countryCode': countryCode,
        'email': email,
        'photoURL': photoURL,
        'role': 'CUSTOMER',
        'status': 'ACTIVE',
        'referredBy': referredByUid,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      if (referredByUid != null) {
        await ApiService.incrementUserInvitesSent(referredByUid, user.uid);
      }

      await appBox.put('isProfileComplete', true);

      state = state.copyWith(isLoading: false);
      if (context.mounted) {
        AppSnackbar.showSuccess(context, l10n.accountCreatedSuccessfully);
        context.go(AppRoutes.home);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: l10n.registrationFailed,
      );
    }
  }
}
