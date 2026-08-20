class BilingualHelper {
  static String get(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      // In a real app, you'd check the current locale here
      // For now, default to English, fallback to Hindi
      return value['en'] ?? value['hi'] ?? '';
    }
    return '';
  }
}
