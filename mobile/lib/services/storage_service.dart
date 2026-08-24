import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Uploads a file to Firebase Storage under the user's KYC directory.
  /// Returns the download URL if successful, or null if failed.
  static Future<String?> uploadKycDocument({
    required File file,
    required String documentType, // e.g., 'aadhar_front', 'pan_card'
  }) async {
    try {
      final user = _auth.currentUser;
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
      
    } catch (e) {
      developer.log('Error uploading KYC document: $e');
      return null;
    }
  }
}
