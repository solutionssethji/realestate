// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  final arbFileEn = File('lib/l10n/app_en.arb');
  final arbFileHi = File('lib/l10n/app_hi.arb');

  if (!arbFileEn.existsSync() || !arbFileHi.existsSync()) {
    print('ARB files not found!');
    return;
  }

  final Map<String, dynamic> enData = jsonDecode(
    await arbFileEn.readAsString(),
  );
  final Map<String, dynamic> hiData = jsonDecode(
    await arbFileHi.readAsString(),
  );

  final enKeys = enData.keys
      .where((k) => !k.startsWith('@') && k != '@@locale')
      .toSet();
  final hiKeys = hiData.keys
      .where((k) => !k.startsWith('@') && k != '@@locale')
      .toSet();

  final missingInHi = enKeys.difference(hiKeys);
  final missingInEn = hiKeys.difference(enKeys);

  bool hasErrors = false;

  if (missingInHi.isNotEmpty) {
    print('❌ Missing in Hindi (app_hi.arb):');
    for (final key in missingInHi) {
      print('  - $key');
    }
    hasErrors = true;
  }

  if (missingInEn.isNotEmpty) {
    print('\n❌ Missing in English (app_en.arb):');
    for (final key in missingInEn) {
      print('  - $key');
    }
    hasErrors = true;
  }

  if (!hasErrors) {
    print('✅ Excellent! All keys match perfectly between English and Hindi.');
  } else {
    print('\n⚠️ Please add the missing keys to fix the translation mismatch.');
  }
}
