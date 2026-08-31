import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'faq.state.dart';
import '../../services/cms_service.dart';
import '../../config/locale_provider.dart';

part 'faq.logic.g.dart';

@riverpod
class FaqLogic extends _$FaqLogic {
  @override
  FaqState build() {
    // Listen to locale changes to trigger a reload if needed,
    // though CmsService.getFaqs() currently doesn't take a locale parameter
    // it's good practice for when it does.
    ref.watch(localeControllerProvider);

    Future.microtask(() => loadFaqs());
    return const FaqState();
  }

  Future<void> loadFaqs() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    final faqs = await CmsService.getFaqs();
    state = state.copyWith(faqs: faqs, isLoading: false);
  }
}
