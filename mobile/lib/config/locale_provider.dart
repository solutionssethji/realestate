import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../main.dart' show appBox;
import '../utils/bilingual_helper.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleController extends _$LocaleController {
  @override
  Locale build() {
    final savedLang = appBox.get('language_code') as String?;
    final langCode = savedLang ?? 'en';
    BilingualHelper.currentLangCode = langCode;
    return Locale(langCode);
  }

  Future<void> setLocale(String languageCode) async {
    await appBox.put('language_code', languageCode);
    BilingualHelper.currentLangCode = languageCode;
    state = Locale(languageCode);
  }
}
