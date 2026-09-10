// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

void main() async {
  final libDir = Directory('lib');
  final arbFileEn = File('lib/l10n/app_en.arb');
  final arbFileHi = File('lib/l10n/app_hi.arb');

  if (!arbFileEn.existsSync() || !arbFileHi.existsSync()) {
    print('ARB files not found!');
    return;
  }

  // 1. Parse ARB files
  Map<String, dynamic> enData = jsonDecode(await arbFileEn.readAsString());
  Map<String, dynamic> hiData = jsonDecode(await arbFileHi.readAsString());

  // 2. Find Used Keys
  final allKeys = enData.keys
      .where((k) => !k.startsWith('@') && k != '@@locale')
      .toList();
  final usedKeys = <String>{};

  final dartFiles = await libDir
      .list(recursive: true)
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  for (var entity in dartFiles) {
    if (entity is File) {
      final content = await entity.readAsString();
      for (final key in allKeys) {
        if (content.contains('.$key') ||
            content.contains("'$key'") ||
            content.contains('"$key"')) {
          usedKeys.add(key);
        }
      }
    }
  }

  final unusedKeys = allKeys.where((k) => !usedKeys.contains(k)).toList();

  if (unusedKeys.isEmpty) {
    print('No unused keys found!');
    return;
  }

  print('Removing ${unusedKeys.length} unused keys...');

  // 3. Remove Unused Keys
  for (final key in unusedKeys) {
    enData.remove(key);
    enData.remove('@$key'); // remove metadata too
    hiData.remove(key);
    hiData.remove('@$key');
  }

  // Write updated ARB
  final encoder = JsonEncoder.withIndent('  ');
  await arbFileEn.writeAsString('${encoder.convert(enData)}\n');
  await arbFileHi.writeAsString('${encoder.convert(hiData)}\n');

  print('✅ Successfully removed unused keys from ARB files!');
}
