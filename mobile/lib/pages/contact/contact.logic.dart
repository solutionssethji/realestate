import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'contact.state.dart';
import '../../services/cms_service.dart';
import '../../config/locale_provider.dart';

part 'contact.logic.g.dart';

@riverpod
class ContactLogic extends _$ContactLogic {
  @override
  ContactState build() {
    final locale = ref.watch(localeControllerProvider);
    Future.microtask(() => loadInfo(locale.languageCode));
    return const ContactState();
  }

  Future<void> loadInfo(String languageCode) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    final info = await CmsService.getContactInfo(languageCode);
    state = state.copyWith(companyInfo: info, isLoading: false);
  }
}
