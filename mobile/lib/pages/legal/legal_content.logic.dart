import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'legal_content.state.dart';
import '../../services/cms_service.dart';
import '../../config/locale_provider.dart';

part 'legal_content.logic.g.dart';

@riverpod
class LegalContentLogic extends _$LegalContentLogic {
  @override
  LegalContentState build(String documentId) {
    final locale = ref.watch(localeControllerProvider);
    Future.microtask(() => loadContent(documentId, locale.languageCode));
    return const LegalContentState();
  }

  Future<void> loadContent(String documentId, String languageCode) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    try {
      final data = await CmsService.getPublicContent(languageCode);
      final contentKey = documentId == 'terms' ? 'termsAndConditions' : 'privacyPolicy';
      final content = data?[contentKey];

      state = state.copyWith(
        content: content,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
