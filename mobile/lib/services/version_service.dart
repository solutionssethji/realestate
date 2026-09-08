import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/models/version_config.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateType { none, normal, force }

class VersionCheckResult {
  final UpdateType updateType;
  final VersionConfig? config;

  VersionCheckResult({required this.updateType, this.config});
}

class VersionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<VersionCheckResult> checkForUpdates() async {
    logApi(function: 'checkForUpdates()', request: {});
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
      final currentBuild =
          int.tryParse(packageInfo.buildNumber) ?? 0; // e.g. 16

      // Parse target from latestVersion (e.g. "1.0.0+17" or "1.1.0+17")
      final targetSplit = config.latestVersion.split('+');
      final targetVer = targetSplit[0];
      final targetBuild = targetSplit.length > 1
          ? (int.tryParse(targetSplit[1]) ?? 0)
          : 0;

      // 1. Agar main version chhota hai (e.g. 1.0.0 < 1.1.0), toh Force Update
      if (_isMainVersionLower(currentVer, targetVer)) {
        return VersionCheckResult(updateType: UpdateType.force, config: config);
      }

      // 2. Agar main version barabar hai, lekin build number chhota hai (e.g. 16 < 17), toh Normal Update
      if (currentVer == targetVer && currentBuild < targetBuild) {
        return VersionCheckResult(
          updateType: UpdateType.normal,
          config: config,
        );
      }
      // Agar same hai ya current bada hai, toh kuch mat dikhao
      return VersionCheckResult(updateType: UpdateType.none);
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'checkForUpdates()',
      );

      return VersionCheckResult(updateType: UpdateType.none);
    }
  }

  // Sirf major.minor.patch compare karta hai (build number nahi)
  bool _isMainVersionLower(String currentVer, String targetVer) {
    try {
      final currentParts = currentVer
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final targetParts = targetVer
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

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
