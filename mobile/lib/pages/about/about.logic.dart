import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'about.state.dart';
import '../../services/cms_service.dart';
import '../../config/locale_provider.dart';

part 'about.logic.g.dart';

@riverpod
class AboutLogic extends _$AboutLogic {
  @override
  AboutState build() {
    final locale = ref.watch(localeControllerProvider);
    Future.microtask(() => loadInfo(locale.languageCode));
    return const AboutState();
  }

  Future<void> loadInfo(String languageCode) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    try {
      final info = await CmsService.getContactInfo(languageCode);
      state = state.copyWith(
        companyInfo: info,
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
