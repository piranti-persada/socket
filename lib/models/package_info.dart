class PackageInfo {
  final String packageName;
  final String? appName;
  final String? versionName;
  final String? installPath;
  final bool isSystem;

  PackageInfo({
    required this.packageName,
    this.appName,
    this.versionName,
    this.installPath,
    this.isSystem = false,
  });
}
