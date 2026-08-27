import '../../../services/api_service.dart';

import 'document_locker.state.dart';

class DocumentLockerLogic {
  const DocumentLockerLogic();

  Future<DocumentLockerState> load(String? userId) async {
    if (userId == null) {
      return const DocumentLockerState(documents: [], isLoading: false);
    }

    final documents = await ApiService.getUserDocuments(userId);
    return DocumentLockerState(documents: documents, isLoading: false);
  }
}
