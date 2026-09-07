class VersionConfig {
  final String latestVersion;
  final String minVersion;
  final String androidUrl;
  final String iosUrl;

  VersionConfig({
    required this.latestVersion,
    required this.minVersion,
    required this.androidUrl,
    required this.iosUrl,
  });

  factory VersionConfig.fromMap(Map<String, dynamic> map) {
    return VersionConfig(
      latestVersion: map['latest_version'] ?? '1.0.0',
      minVersion: map['min_version'] ?? '1.0.0',
      androidUrl: map['android_url'] ?? '',
      iosUrl: map['ios_url'] ?? '',
    );
  }
}
