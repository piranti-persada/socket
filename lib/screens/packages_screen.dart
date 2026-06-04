import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_providers.dart';
import '../providers/package_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/package_tile.dart';
import '../core/theme/app_colors.dart';

class PackagesScreen extends ConsumerWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDevice = ref.watch(selectedDeviceProvider);
    final packagesAsync = ref.watch(packagesProvider);
    final filteredPackages = ref.watch(filteredPackagesProvider);
    final filter = ref.watch(packageFilterProvider);

    if (selectedDevice == null) {
      return const EmptyState(
        icon: Icons.apps,
        title: 'Packages',
        message: 'Select a device to view installed apps.',
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search packages...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => ref.read(packagesSearchQueryProvider.notifier).state = value,
                ),
              ),
              const SizedBox(width: 16),
              SegmentedButton<PackageFilterType>(
                segments: const [
                  ButtonSegment(value: PackageFilterType.all, label: Text('All')),
                  ButtonSegment(value: PackageFilterType.user, label: Text('User')),
                  ButtonSegment(value: PackageFilterType.system, label: Text('System')),
                ],
                selected: {filter},
                onSelectionChanged: (set) => ref.read(packageFilterProvider.notifier).state = set.first,
                style: SegmentedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  selectedForegroundColor: AppColors.textPrimary,
                  selectedBackgroundColor: AppColors.primary.withOpacity(0.2),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(packagesProvider),
              ),
            ],
          ),
        ),
        Expanded(
          child: packagesAsync.when(
            data: (_) {
              if (filteredPackages.isEmpty) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'No packages found',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPackages.length,
                itemBuilder: (context, index) {
                  return PackageTile(package: filteredPackages[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading packages: $e')),
          ),
        ),
      ],
    );
  }
}
