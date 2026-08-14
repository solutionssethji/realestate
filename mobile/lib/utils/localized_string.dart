import 'package:flutter/material.dart';

/// Helper to parse { "en": "...", "hi": "..." } maps from Firestore.
String getLocalizedText(
  BuildContext context,
  dynamic data, {
  String defaultVal = '',
}) {
  if (data == null) return defaultVal;

  if (data is String) return data;

  if (data is Map) {
    // Get the current locale language code (e.g., 'en' or 'hi')
    final locale = Localizations.localeOf(context).languageCode;

    // Attempt to get the localized string, fallback to English, then default.
    return data[locale] as String? ?? data['en'] as String? ?? defaultVal;
  }

  return defaultVal;
}
