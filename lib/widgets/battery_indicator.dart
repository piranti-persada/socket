import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class BatteryIndicator extends StatelessWidget {
  final int level;
  final bool isCharging;
  final double size;

  const BatteryIndicator({
    super.key,
    required this.level,
    required this.isCharging,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.success;
    if (level <= 20) {
      color = AppColors.error;
    } else if (level <= 50) {
      color = AppColors.warning;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: level / 100,
            strokeWidth: 6,
            color: color,
            backgroundColor: AppColors.surface,
          ),
          if (isCharging)
            Icon(Icons.bolt, color: color, size: size * 0.5)
          else
            Text(
              '$level%',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
