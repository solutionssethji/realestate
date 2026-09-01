import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'edit_profile.state.dart';

part 'edit_profile.logic.g.dart';

@riverpod
class EditProfileLogic extends _$EditProfileLogic {
  @override
  EditProfileState build() {
    return const EditProfileState();
  }

  Future<bool> updateProfile({
    required String fullName,
    required String mobileNumber,
    XFile? newProfileImage,
    bool removeExistingPhoto = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'User not found. Please log in again.',
        );
        return false;
      }

      String? photoURL;

      if (newProfileImage != null) {
        final downloadUrl = await StorageService.uploadProfileImage(
          uid: user.uid,
          file: File(newProfileImage.path),
        );
        if (downloadUrl != null) {
          photoURL = downloadUrl;
        }
      }

      final data = <String, dynamic>{
        'fullName': fullName,
        'mobileNumber': mobileNumber,
      };

      if (photoURL != null) {
        data['photoURL'] = photoURL;
      } else if (removeExistingPhoto) {
        data['photoURL'] = '';
      }

      await ApiService.updateUserProfile(user.uid, data);

      if (fullName != user.displayName ||
          photoURL != null ||
          removeExistingPhoto) {
        if (user.photoURL != null &&
            user.photoURL!.isNotEmpty &&
            (photoURL != null || removeExistingPhoto)) {
          try {
            await CachedNetworkImageProvider(user.photoURL!).evict();
          } catch (_) {}
        }
        await user.updateDisplayName(fullName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        } else if (removeExistingPhoto) {
          await user.updatePhotoURL('');
        }
      }

      // Refresh customer data provider so the UI updates globally
      ref.invalidate(customerProvider);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
