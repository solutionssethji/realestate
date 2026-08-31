import 'dart:io';
import 'package:customer_app/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../services/auth_service.dart';
import 'dart:developer' as developer;
import '../utils/snackbar_utils.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a file to Firebase Storage under the user's KYC directory.
  /// Returns the download URL if successful, or null if failed.
  static Future<String?> uploadKycDocument({
    required File file,
    required String documentType, // e.g., 'aadhar_front', 'pan_card'
  }) async {
    try {
      final user = AuthService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create a unique file name using timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = file.path.split('.').last;
      final fileName = '${documentType}_$timestamp.$fileExtension';

      // Path: users/{uid}/kyc/{fileName}
      final ref = _storage.ref().child('users/${user.uid}/kyc/$fileName');

      developer.log('Uploading $documentType to ${ref.fullPath}');

      // Upload file
      final uploadTask = await ref.putFile(file);

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      developer.log('Upload successful. URL: $downloadUrl');
      return downloadUrl;
    } on FirebaseAuthException catch (e) {
      AppSnackbar.showGlobalError(e.toString());

      developer.log('Error uploading KYC document: $e');
      logApi(
        function: 'uploadKycDocument()',
        error: FirebaseAuthErrorMapper.getMessage(e.code),
      );
      return null;
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'uploadKycDocument()');
      return null;
    }
  }

  /// Uploads a profile image to Firebase Storage under the user's profile directory.
  static Future<String?> uploadProfileImage({
    required String uid,
    required File file,
  }) async {
    try {
      final ref = _storage.ref().child('users/$uid/profile.jpg');
      developer.log('Uploading profile image to ${ref.fullPath}');
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      developer.log('Upload successful. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'uploadProfileImage()');
      return null;
    }
  }
}
