import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_providers.dart';
import '../widgets/stat_tile.dart';
import '../widgets/battery_indicator.dart';
import '../widgets/storage_bar.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/empty_state.dart';
import '../models/device_status.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDevice = ref.watch(selectedDeviceProvider);

    if (selectedDevice == null) {
      return const EmptyState(
        icon: Icons.dashboard,
        title: 'Select a Device',
        message: 'Choose a device from the left panel to view its dashboard.',
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selectedDevice.connectionType == DeviceConnectionType.wifi ? Icons.wifi : Icons.usb,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedDevice.model,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Text(
                        '${selectedDevice.manufacturer} • ${selectedDevice.serial}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(context, selectedDevice.status),
              ],
            ),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                StatTile(
                  title: 'Android Version',
                  value: selectedDevice.androidVersion,
                  icon: Icons.android,
                ),
                StatTile(
                  title: 'SDK Version',
                  value: selectedDevice.sdkVersion.toString(),
                  icon: Icons.code,
                ),
                StatTile(
                  title: 'Build',
                  value: selectedDevice.buildNumber,
                  icon: Icons.build,
                ),
                StatTile(
                  title: 'Status',
                  value: selectedDevice.status.name.toUpperCase(),
                  icon: Icons.info_outline,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedDevice.battery != null) ...[
                  Expanded(
                    child: GlassCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Battery', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text('Health: ${selectedDevice.battery!.health}'),
                              Text('Temp: ${selectedDevice.battery!.temperature.toStringAsFixed(1)}°C'),
                            ],
                          ),
                          BatteryIndicator(
                            level: selectedDevice.battery!.level,
                            isCharging: selectedDevice.battery!.isCharging,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (selectedDevice.storage != null) ...[
                  Expanded(
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Storage', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 16),
                          StorageBar(
                            percentage: selectedDevice.storage!.percentageUsed,
                            label: '${(selectedDevice.storage!.usedBytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB / ${(selectedDevice.storage!.totalBytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                QuickActionButton(
                  icon: Icons.camera_alt,
                  label: 'Screenshot',
                  onTap: () {},
                ),
                QuickActionButton(
                  icon: Icons.videocam,
                  label: 'Record',
                  onTap: () {},
                ),
                QuickActionButton(
                  icon: Icons.receipt_long,
                  label: 'Logcat',
                  onTap: () {},
                ),
                QuickActionButton(
                  icon: Icons.apps,
                  label: 'Apps',
                  onTap: () {},
                ),
                QuickActionButton(
                  icon: Icons.restart_alt,
                  label: 'Reboot',
                  color: Colors.orange,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, DeviceStatus status) {
    Color color;
    switch (status) {
      case DeviceStatus.connected:
        color = Colors.green;
        break;
      case DeviceStatus.unauthorized:
        color = Colors.orange;
        break;
      case DeviceStatus.offline:
        color = Colors.red;
        break;
      case DeviceStatus.fastboot:
        color = Colors.blue;
        break;
      case DeviceStatus.unknown:
      default:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
