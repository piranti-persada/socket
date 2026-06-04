import 'package:flutter/material.dart';
import '../models/device.dart';
import '../core/theme/app_colors.dart';
import 'device_status_badge.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final bool isSelected;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                device.connectionType == DeviceConnectionType.wifi ? Icons.wifi : 
                device.connectionType == DeviceConnectionType.emulator ? Icons.phone_android : Icons.usb,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.model,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      device.serial,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (device.battery != null) ...[
                const SizedBox(width: 8),
                _buildBatteryMini(device.battery!.level, device.battery!.isCharging),
              ],
              const SizedBox(width: 12),
              DeviceStatusBadge(status: device.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryMini(int level, bool isCharging) {
    Color color = AppColors.success;
    if (level < 20) color = AppColors.error;
    else if (level < 50) color = AppColors.warning;

    return Row(
      children: [
        if (isCharging)
          Icon(Icons.bolt, size: 12, color: color),
        Text(
          '$level%',
          style: TextStyle(fontSize: 11, color: color),
        ),
      ],
    );
  }
}
