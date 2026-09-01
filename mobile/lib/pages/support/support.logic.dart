import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import '../../services/cms_service.dart';
import '../../config/locale_provider.dart';
import 'support.state.dart';

part 'support.logic.g.dart';

@riverpod
class SupportLogic extends _$SupportLogic {
  @override
  SupportState build() {
    final locale = ref.watch(localeControllerProvider);
    Future.microtask(() => loadInfo(locale.languageCode));
    return const SupportState();
  }

  Future<void> loadInfo(String languageCode) async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final info = await CmsService.getContactInfo(languageCode);
      state = state.copyWith(companyInfo: info, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> launchSupportUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }
}
