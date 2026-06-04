import 'package:flutter/material.dart';
import '../models/logcat_entry.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class LogcatEntryTile extends StatelessWidget {
  final LogcatEntry entry;

  const LogcatEntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    Color levelColor;
    switch (entry.level) {
      case LogLevel.verbose: levelColor = Colors.grey; break;
      case LogLevel.debug: levelColor = Colors.blue; break;
      case LogLevel.info: levelColor = Colors.green; break;
      case LogLevel.warning: levelColor = Colors.orange; break;
      case LogLevel.error: levelColor = Colors.red; break;
      case LogLevel.fatal: levelColor = Colors.redAccent; break;
      default: levelColor = AppColors.textPrimary; break;
    }

    if (entry.level == LogLevel.unknown) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Text(
          entry.rawLine,
          style: AppTypography.codeStyle.copyWith(color: AppColors.textPrimary),
        ),
      );
    }

    final timeStr = entry.timestamp != null 
        ? '${entry.timestamp!.hour.toString().padLeft(2, '0')}:${entry.timestamp!.minute.toString().padLeft(2, '0')}:${entry.timestamp!.second.toString().padLeft(2, '0')}.${entry.timestamp!.millisecond.toString().padLeft(3, '0')}'
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              timeStr,
              style: AppTypography.codeStyle.copyWith(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(
            width: 24,
            child: Text(
              entry.level.name[0].toUpperCase(),
              style: AppTypography.codeStyle.copyWith(color: levelColor, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              entry.tag,
              style: AppTypography.codeStyle.copyWith(color: levelColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              entry.message,
              style: AppTypography.codeStyle.copyWith(color: levelColor),
            ),
          ),
        ],
      ),
    );
  }
}
