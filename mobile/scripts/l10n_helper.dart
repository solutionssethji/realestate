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

  // 2. Sort ARB alphabetically
  Map<String, dynamic> sortArb(Map<String, dynamic> data) {
    final metadata = <String, dynamic>{};
    final keys = <String, dynamic>{};

    data.forEach((key, value) {
      if (key.startsWith('@') && key != '@@locale') {
        metadata[key] = value;
      } else {
        keys[key] = value;
      }
    });

    final sortedKeys = keys.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final sortedData = <String, dynamic>{};
    if (data.containsKey('@@locale')) {
      sortedData['@@locale'] = data['@@locale'];
    }
    for (final key in sortedKeys) {
      sortedData[key] = keys[key];
      if (metadata.containsKey('@$key')) {
        sortedData['@$key'] = metadata['@$key'];
      }
    }
    return sortedData;
  }

  enData = sortArb(enData);
  hiData = sortArb(hiData);

  // Write sorted ARB
  final encoder = JsonEncoder.withIndent('  ');
  await arbFileEn.writeAsString('${encoder.convert(enData)}\n');
  await arbFileHi.writeAsString('${encoder.convert(hiData)}\n');
  print('✅ ARB files sorted alphabetically.');

  // 3. Find Unused Keys
  final allKeys = enData.keys
      .where((k) => !k.startsWith('@') && k != '@@locale')
      .toList();
  final usedKeys = <String>{};

  final dartFiles = await libDir
      .list(recursive: true)
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  // Potential hardcoded string regex
  final hardcodedRegex = RegExp(r'''Text\(\s*['"]([^'"]+)['"]''');
  final textSpanRegex = RegExp(r'''TextSpan\(\s*text:\s*['"]([^'"]+)['"]''');
  final labelRegex = RegExp(r'''label:\s*['"]([^'"]+)['"]''');
  final hintTextRegex = RegExp(r'''hintText:\s*['"]([^'"]+)['"]''');
  final titleRegex = RegExp(r'''title:\s*['"]([^'"]+)['"]''');

  final hardcodedFindings = <String>[];

  for (var entity in dartFiles) {
    if (entity is File) {
      final content = await entity.readAsString();

      // Check for used keys
      for (final key in allKeys) {
        if (content.contains('.$key') ||
            content.contains("'$key'") ||
            content.contains('"$key"')) {
          usedKeys.add(key);
        }
      }

      // Check for hardcoded strings
      void checkMatches(RegExp regex, String type) {
        if (entity.path.endsWith('language_selection.page.dart') ||
            entity.path.endsWith('payment_receipt_service.dart')) {
          return;
        }

        final matches = regex.allMatches(content);
        for (final m in matches) {
          final matchedStr = m.group(1);
          if (matchedStr != null &&
              matchedStr.isNotEmpty &&
              !matchedStr.startsWith('\$')) {
            hardcodedFindings.add('${entity.path}: $type("$matchedStr")');
          }
        }
      }

      checkMatches(hardcodedRegex, 'Text');
      checkMatches(textSpanRegex, 'TextSpan');
      checkMatches(labelRegex, 'label');
      checkMatches(hintTextRegex, 'hintText');
      checkMatches(titleRegex, 'title');
    }
  }

  final unusedKeys = allKeys.where((k) => !usedKeys.contains(k)).toList();

  print('\n🔍 UNUSED KEYS (${unusedKeys.length}):');
  for (var k in unusedKeys) {
    print('  - $k');
  }

  print('\n⚠️ POTENTIAL HARDCODED STRINGS (${hardcodedFindings.length}):');
  for (var f in hardcodedFindings) {
    print('  - $f');
  }
}
