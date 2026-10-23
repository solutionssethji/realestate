class VersionConfig {
  final String latestVersion;
  final String minVersion;
  final String androidUrl;
  final String iosUrl;
  final bool isMaintenance;
  final String maintenanceMessage;

  VersionConfig({
    required this.latestVersion,
    required this.minVersion,
    required this.androidUrl,
    required this.iosUrl,
    this.isMaintenance = false,
    this.maintenanceMessage =
        'We are currently performing scheduled maintenance to improve your experience. Please check back shortly.',
  });

  factory VersionConfig.fromMap(Map<String, dynamic> map) {
    return VersionConfig(
      latestVersion: map['latest_version'] ?? '1.0.0',
      minVersion: map['min_version'] ?? '1.0.0',
      androidUrl: map['android_url'] ?? '',
      iosUrl: map['ios_url'] ?? '',
      isMaintenance: (map['is_maintenance'] as bool?) ?? false,
      maintenanceMessage:
          (map['maintenance_message'] as String?)?.isNotEmpty == true
          ? map['maintenance_message']
          : 'We are currently performing scheduled maintenance to improve your experience. Please check back shortly.',
    );
  }
}
