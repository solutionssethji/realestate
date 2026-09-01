import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import 'register.state.dart';

part 'register.logic.g.dart';

@riverpod
class RegisterLogic extends _$RegisterLogic {
  @override
  RegisterState build() {
    return const RegisterState();
  }

  void toggleObscure() {
    state = state.copyWith(isObscure: !state.isObscure);
  }

  Future<bool> register({
    required String name,
    required String mobile,
    required String email,
    required String password,
    String? referralCode,
    XFile? profileImage,
  }) async {
    if (name.isEmpty || mobile.isEmpty || email.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please fill all fields');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    String? referredByUid;
    if (referralCode != null && referralCode.isNotEmpty) {
      final referrer = await ApiService.getUserByReferralCode(referralCode);
      if (referrer == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid referral code',
        );
        return false;
      }
      referredByUid = referrer['id']?.toString();
    }

    final userCredential = await AuthService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential == null) {
      state = state.copyWith(isLoading: false);
      return false;
    }

    // Create user document in Firestore
    if (userCredential.user != null) {
      String photoURL = '';

      if (profileImage != null) {
        final downloadUrl = await StorageService.uploadProfileImage(
          uid: userCredential.user!.uid,
          file: File(profileImage.path),
        );
        if (downloadUrl != null) {
          photoURL = downloadUrl;
        }
      }

      await ApiService.createUserProfile(userCredential.user!.uid, {
        'id': userCredential.user!.uid,
        'fullName': name,
        'mobileNumber': mobile,
        'email': email,
        'photoURL': photoURL,
        'role': 'CUSTOMER',
        'status': 'ACTIVE',
        'referredBy': ?referredByUid,
        'createdAt': DateTime.now()
            .toIso8601String(), // Or omit if handled server side
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    // Send email verification
    if (userCredential.user != null && !userCredential.user!.emailVerified) {
      await userCredential.user!.sendEmailVerification();
      // We sign out the user so they have to login after verifying
      await AuthService.signOut();
    }

    state = state.copyWith(isLoading: false);
    return true;
  }
}
