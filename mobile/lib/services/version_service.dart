import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/version_config.dart';

enum UpdateType { none, normal, force }

class VersionCheckResult {
  final UpdateType updateType;
  final VersionConfig? config;

  VersionCheckResult({required this.updateType, this.config});
}

class VersionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<VersionCheckResult> checkForUpdates() async {
    try {
      final doc = await _firestore
          .collection('app_config')
          .doc('version')
          .get();
      if (!doc.exists || doc.data() == null) {
        return VersionCheckResult(updateType: UpdateType.none);
      }

      final config = VersionConfig.fromMap(doc.data()!);
      final packageInfo = await PackageInfo.fromPlatform();
      
      final currentVer = packageInfo.version; // e.g. "1.0.0"
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0; // e.g. 16

      // Parse target from latestVersion (e.g. "1.0.0+17" or "1.1.0+17")
      final targetSplit = config.latestVersion.split('+');
      final targetVer = targetSplit[0];
      final targetBuild = targetSplit.length > 1 ? (int.tryParse(targetSplit[1]) ?? 0) : 0;

      // 1. If main version is lower (e.g. 1.0.0 < 1.1.0), force update
      if (_isMainVersionLower(currentVer, targetVer)) {
        return VersionCheckResult(updateType: UpdateType.force, config: config);
      }

      // 2. If main version is equal, but build number is lower (e.g. 16 < 17), normal update
      if (currentVer == targetVer && currentBuild < targetBuild) {
        return VersionCheckResult(
          updateType: UpdateType.normal,
          config: config,
        );
      }

      // If equal or current is higher, no update needed
      return VersionCheckResult(updateType: UpdateType.none);
    } catch (e) {
      return VersionCheckResult(updateType: UpdateType.none);
    }
  }

  // Compare major.minor.patch (ignore build number)
  bool _isMainVersionLower(String currentVer, String targetVer) {
    try {
      final currentParts =
          currentVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final targetParts =
          targetVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (int i = 0; i < 3; i++) {
        final c = i < currentParts.length ? currentParts[i] : 0;
        final t = i < targetParts.length ? targetParts[i] : 0;

        if (c < t) return true;
        if (c > t) return false;
      }
      return false; // Both are exactly equal
    } catch (e) {
      return false;
    }
  }
}
