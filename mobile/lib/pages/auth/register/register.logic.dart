import 'dart:developer';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    XFile? profileImage,
  }) async {
    if (name.isEmpty || mobile.isEmpty || email.isEmpty || password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please fill all fields');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userCredential = await AuthService.createUserWithEmailAndPassword(
          email: email, password: password);

      // Create user document in Firestore
      if (userCredential.user != null) {
        String photoURL = '';

        if (profileImage != null) {
          try {
            final downloadUrl = await StorageService.uploadProfileImage(
              uid: userCredential.user!.uid,
              file: File(profileImage.path),
            );
            if (downloadUrl != null) {
              photoURL = downloadUrl;
            }
          } catch (e) {
            log("Failed to upload profile image: $e");
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
          'createdAt': DateTime.now().toIso8601String(), // Or omit if handled server side
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message ?? 'Registration failed',
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
