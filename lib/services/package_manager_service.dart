import '../core/constants/app_constants.dart';
import '../core/utils/process_runner.dart';
import '../models/package_info.dart';

class PackageManagerService {
  Future<List<PackageInfo>> listPackages(String serial) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'shell', 'pm', 'list', 'packages', '-f']);
    if (!result.isSuccess) return [];

    final lines = result.stdout.split('\n');
    final packages = <PackageInfo>[];

    for (final line in lines) {
      if (line.trim().isEmpty || !line.startsWith('package:')) continue;
      
      final content = line.trim().substring(8); // remove 'package:'
      final equalsIndex = content.lastIndexOf('=');
      if (equalsIndex != -1) {
        final path = content.substring(0, equalsIndex);
        final name = content.substring(equalsIndex + 1);
        final isSystem = path.startsWith('/system/') || path.startsWith('/vendor/') || path.startsWith('/product/');
        
        packages.add(PackageInfo(
          packageName: name,
          installPath: path,
          isSystem: isSystem,
          appName: name.split('.').last, // Temporary placeholder for actual app name
        ));
      }
    }

    packages.sort((a, b) => a.packageName.compareTo(b.packageName));
    return packages;
  }

  Future<bool> launchApp(String serial, String packageName) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'shell', 'monkey', '-p', packageName, '-c', 'android.intent.category.LAUNCHER', '1']);
    return result.isSuccess;
  }

  Future<bool> forceStop(String serial, String packageName) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'shell', 'am', 'force-stop', packageName]);
    return result.isSuccess;
  }

  Future<bool> clearData(String serial, String packageName) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'shell', 'pm', 'clear', packageName]);
    return result.isSuccess;
  }

  Future<bool> uninstall(String serial, String packageName) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'uninstall', packageName]);
    return result.isSuccess;
  }
}
