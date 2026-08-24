import 'dart:developer';
import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      if (userCredential.user != null) {
        String photoURL = '';

        if (profileImage != null) {
          try {
            final storageRef = FirebaseStorage.instance.ref().child(
              'users/${userCredential.user!.uid}/profile.jpg',
            );
            await storageRef.putFile(File(profileImage.path));
            photoURL = await storageRef.getDownloadURL();
          } catch (e) {
            log("Failed to upload profile image: $e");
          }
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'id': userCredential.user!.uid,
              'fullName': name,
              'mobileNumber': mobile,
              'email': email,
              'photoURL': photoURL,
              'role': 'CUSTOMER',
              'status': 'ACTIVE',
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
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
