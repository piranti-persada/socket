import 'package:flutter/material.dart';
import '../models/device_status.dart';
import '../core/theme/app_colors.dart';

class DeviceStatusBadge extends StatelessWidget {
  final DeviceStatus status;
  final double size;

  const DeviceStatusBadge({
    super.key,
    required this.status,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case DeviceStatus.connected:
        color = AppColors.statusConnected;
        break;
      case DeviceStatus.unauthorized:
        color = AppColors.statusUnauthorized;
        break;
      case DeviceStatus.offline:
        color = AppColors.statusOffline;
        break;
      case DeviceStatus.fastboot:
        color = AppColors.statusFastboot;
        break;
      case DeviceStatus.unknown:
      default:
        color = AppColors.textSecondary;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          )
        ],
      ),
    );
  }
}
