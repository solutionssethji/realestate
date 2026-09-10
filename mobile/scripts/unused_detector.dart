// ignore_for_file: avoid_print

import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  final bool deleteMode = args.contains('--delete');

  print('🔍 Scanning for unused assets and Dart files...\n');

  final libDir = Directory('lib');
  final assetsDir = Directory('assets');

  final List<File> allDartFiles = [];
  if (libDir.existsSync()) {
    allDartFiles.addAll(
      libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
    );
  }

  // 1. Find Unused Assets
  final List<File> unusedAssets = [];
  if (assetsDir.existsSync()) {
    final assetFiles = assetsDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => !f.path.endsWith('.DS_Store'));

    for (final asset in assetFiles) {
      final assetName = p.basename(asset.path);
      bool isUsed = false;

      for (final dartFile in allDartFiles) {
        final content = dartFile.readAsStringSync();
        if (content.contains(assetName)) {
          isUsed = true;
          break;
        }
      }

      if (!isUsed) {
        unusedAssets.add(asset);
      }
    }
  }

  // 2. Find Unused Dart Files (Heuristic: is the filename ever imported/mentioned?)
  final List<File> unusedDartFiles = [];
  final ignoreFiles = ['main.dart', 'firebase_options.dart'];

  for (final targetFile in allDartFiles) {
    final targetName = p.basename(targetFile.path);
    if (ignoreFiles.contains(targetName)) continue;
    if (targetFile.path.contains('.freezed.dart') ||
        targetFile.path.contains('.g.dart')) {
      continue; // Ignore generated files
    }

    bool isUsed = false;
    for (final otherFile in allDartFiles) {
      if (targetFile.path == otherFile.path) continue;

      final content = otherFile.readAsStringSync();
      // Simple heuristic: if the exact filename is mentioned anywhere in another file (like import 'xyz.dart')
      if (content.contains(targetName)) {
        isUsed = true;
        break;
      }
    }

    if (!isUsed) {
      unusedDartFiles.add(targetFile);
    }
  }

  // 3. Print Results
  if (unusedAssets.isEmpty && unusedDartFiles.isEmpty) {
    print('✅ Clean! No unused assets or unused Dart files found.');
    return;
  }

  if (unusedAssets.isNotEmpty) {
    print('⚠️ UNUSED ASSETS (${unusedAssets.length}):');
    for (var f in unusedAssets) {
      print('  - ${f.path}');
    }
    print('');
  }

  if (unusedDartFiles.isNotEmpty) {
    print('⚠️ POTENTIAL UNUSED DART FILES (${unusedDartFiles.length}):');
    print(
      '  (Note: Double check these before deleting, as they might be used dynamically or be top-level routes)',
    );
    for (var f in unusedDartFiles) {
      print('  - ${f.path}');
    }
    print('');
  }

  // 4. Delete Mode
  if (deleteMode) {
    print('🗑️ DELETING UNUSED FILES...');
    int deletedAssets = 0;
    int deletedDart = 0;

    for (var f in unusedAssets) {
      f.deleteSync();
      deletedAssets++;
    }

    for (var f in unusedDartFiles) {
      f.deleteSync();
      deletedDart++;
    }

    print(
      '✅ Deleted $deletedAssets unused assets and $deletedDart unused Dart files.',
    );
  } else {
    print('💡 To automatically delete these files, run:');
    print('   fvm dart scripts/unused_detector.dart --delete');
  }
}
