import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_providers.dart';
import 'device_card.dart';
import 'empty_state.dart';

class DeviceListPanel extends ConsumerWidget {
  const DeviceListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceListState = ref.watch(deviceListProvider);
    final selectedDevice = ref.watch(selectedDeviceProvider);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Devices',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (deviceListState.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Expanded(
            child: deviceListState.when(
              data: (devices) {
                if (devices.isEmpty) {
                  return const EmptyState(
                    icon: Icons.devices,
                    title: 'No devices',
                    message: 'Connect a device via USB or Wireless.',
                  );
                }

                // Auto-select first device if none selected
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (selectedDevice == null && devices.isNotEmpty) {
                    ref.read(selectedDeviceProvider.notifier).state = devices.first;
                  }
                });

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: devices.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return DeviceCard(
                      device: device,
                      isSelected: selectedDevice?.serial == device.serial,
                      onTap: () {
                        ref.read(selectedDeviceProvider.notifier).state = device;
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading devices: $e', textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
