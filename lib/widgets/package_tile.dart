import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/package_info.dart';
import '../core/theme/app_colors.dart';
import '../providers/device_providers.dart';
import '../providers/package_providers.dart';

class PackageTile extends ConsumerStatefulWidget {
  final PackageInfo package;

  const PackageTile({super.key, required this.package});

  @override
  ConsumerState<PackageTile> createState() => _PackageTileState();
}

class _PackageTileState extends ConsumerState<PackageTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered ? AppColors.primary.withOpacity(0.5) : Colors.transparent,
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.package.isSystem ? Icons.android : Icons.apps,
              color: widget.package.isSystem ? AppColors.textSecondary : AppColors.primary,
            ),
          ),
          title: Text(widget.package.appName ?? widget.package.packageName),
          subtitle: Text(
            widget.package.packageName,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          trailing: _isHovered ? _buildActions(context, ref) : null,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.play_arrow),
          tooltip: 'Launch',
          onPressed: () async {
            final device = ref.read(selectedDeviceProvider);
            if (device != null) {
              await ref.read(packageManagerServiceProvider).launchApp(device.serial, widget.package.packageName);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          tooltip: 'Force Stop',
          onPressed: () async {
            final device = ref.read(selectedDeviceProvider);
            if (device != null) {
              await ref.read(packageManagerServiceProvider).forceStop(device.serial, widget.package.packageName);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_sweep),
          tooltip: 'Clear Data',
          onPressed: () async {
            final device = ref.read(selectedDeviceProvider);
            if (device != null) {
              await ref.read(packageManagerServiceProvider).clearData(device.serial, widget.package.packageName);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: AppColors.error),
          tooltip: 'Uninstall',
          onPressed: () async {
            final device = ref.read(selectedDeviceProvider);
            if (device != null) {
              await ref.read(packageManagerServiceProvider).uninstall(device.serial, widget.package.packageName);
              ref.invalidate(packagesProvider); // Refresh list
            }
          },
        ),
      ],
    );
  }
}
