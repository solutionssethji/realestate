import 'dart:io';

import '../../services/storage_service.dart';

class KycLogic {
  const KycLogic();

  Future<String?> uploadDocument({
    required File file,
    required String documentType,
  }) {
    return StorageService.uploadKycDocument(
      file: file,
      documentType: documentType,
    );
  }
}
