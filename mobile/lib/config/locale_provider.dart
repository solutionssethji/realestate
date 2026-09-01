import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/bilingual_helper.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleController extends _$LocaleController {
  @override
  Locale build() {
    _loadLocale();
    BilingualHelper.currentLangCode = 'en';
    return const Locale('en'); // Default to English synchronously, updates when async completes
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code');
    if (langCode != null) {
      BilingualHelper.currentLangCode = langCode;
      state = Locale(langCode);
    }
  }

  Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    BilingualHelper.currentLangCode = languageCode;
    state = Locale(languageCode);
  }
}
