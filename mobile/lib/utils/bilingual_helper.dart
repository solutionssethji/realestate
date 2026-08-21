class BilingualHelper {
  static String currentLangCode = 'en';

  static String get(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      return value[currentLangCode] ?? value['en'] ?? '';
    }
    return '';
  }
}
