import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/models/version_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateType { none, normal, force, maintenance }

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

      // 0. Maintenance Mode Check
      if (config.isMaintenance) {
        return VersionCheckResult(
          updateType: UpdateType.maintenance,
          config: config,
        );
      }

      final packageInfo = await PackageInfo.fromPlatform();

      final currentVer = packageInfo.version; // e.g. "1.0.0"
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0; // e.g. 1

      // 1. Force Update Check via min_version (e.g. "1.0.0" or "1.0.0+2")
      if (config.minVersion.isNotEmpty) {
        if (_isVersionBelow(currentVer, currentBuild, config.minVersion)) {
          return VersionCheckResult(
            updateType: UpdateType.force,
            config: config,
          );
        }
      }

      // 2. Normal Update Check via latestVersion (e.g. "1.0.0+2")
      if (config.latestVersion.isNotEmpty) {
        if (_isVersionBelow(currentVer, currentBuild, config.latestVersion)) {
          return VersionCheckResult(
            updateType: UpdateType.normal,
            config: config,
          );
        }
      }

      return VersionCheckResult(updateType: UpdateType.none);
    } catch (e) {
      return VersionCheckResult(updateType: UpdateType.none);
    }
  }

  /// Returns true if (currVer, currBuild) is strictly less than targetVersionString
  /// targetVersionString can be "1.0.0", "1.0.0+2", "1.1.0", etc.
  bool _isVersionBelow(
    String currVer,
    int currBuild,
    String targetVersionString,
  ) {
    try {
      final targetSplit = targetVersionString.split('+');
      final targetVer = targetSplit[0].trim();
      final targetBuild =
          targetSplit.length > 1 ? (int.tryParse(targetSplit[1].trim()) ?? 0) : null;

      final currParts =
          currVer.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
      final targetParts =
          targetVer.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();

      // Compare Major.Minor.Patch
      for (int i = 0; i < 3; i++) {
        final c = i < currParts.length ? currParts[i] : 0;
        final t = i < targetParts.length ? targetParts[i] : 0;

        if (c < t) return true;
        if (c > t) return false;
      }

      // Semver parts are equal, now compare build numbers if target specified a build
      if (targetBuild != null && targetBuild > 0) {
        return currBuild < targetBuild;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
