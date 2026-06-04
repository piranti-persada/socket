import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class StorageBar extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final String label;

  const StorageBar({
    super.key,
    required this.percentage,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.primary;
    if (percentage > 0.9) {
      color = AppColors.error;
    } else if (percentage > 0.75) {
      color = AppColors.warning;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Storage Usage', style: Theme.of(context).textTheme.labelLarge),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppColors.surface,
            color: color,
          ),
        ),
      ],
    );
  }
}
