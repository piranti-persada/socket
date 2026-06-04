import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/package_info.dart';
import '../services/package_manager_service.dart';
import 'device_providers.dart';

final packageManagerServiceProvider = Provider<PackageManagerService>((ref) {
  return PackageManagerService();
});

final packagesSearchQueryProvider = StateProvider<String>((ref) => '');
final packageFilterProvider = StateProvider<PackageFilterType>((ref) => PackageFilterType.all);

enum PackageFilterType { all, user, system }

final packagesProvider = FutureProvider<List<PackageInfo>>((ref) async {
  final selectedDevice = ref.watch(selectedDeviceProvider);
  if (selectedDevice == null) return [];
  
  final service = ref.watch(packageManagerServiceProvider);
  return await service.listPackages(selectedDevice.serial);
});

final filteredPackagesProvider = Provider<List<PackageInfo>>((ref) {
  final packages = ref.watch(packagesProvider).valueOrNull ?? [];
  final query = ref.watch(packagesSearchQueryProvider).toLowerCase();
  final filter = ref.watch(packageFilterProvider);

  return packages.where((pkg) {
    if (filter == PackageFilterType.system && !pkg.isSystem) return false;
    if (filter == PackageFilterType.user && pkg.isSystem) return false;
    
    if (query.isNotEmpty) {
      return pkg.packageName.toLowerCase().contains(query) || 
             (pkg.appName?.toLowerCase().contains(query) ?? false);
    }
    return true;
  }).toList();
});
