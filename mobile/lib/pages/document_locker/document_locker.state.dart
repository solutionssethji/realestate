class DocumentLockerState {
  final List<Map<String, dynamic>> documents;
  final bool isLoading;

  const DocumentLockerState({this.documents = const [], this.isLoading = true});

  DocumentLockerState copyWith({
    List<Map<String, dynamic>>? documents,
    bool? isLoading,
  }) {
    return DocumentLockerState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
