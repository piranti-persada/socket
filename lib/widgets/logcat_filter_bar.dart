import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/logcat_providers.dart';
import '../models/logcat_entry.dart';
import '../core/theme/app_colors.dart';

class LogcatFilterBar extends ConsumerWidget {
  const LogcatFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(logcatNotifierProvider);
    final notifier = ref.read(logcatNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
            color: state.isPaused ? AppColors.success : AppColors.primary,
            onPressed: () => notifier.togglePause(),
            tooltip: state.isPaused ? 'Resume' : 'Pause',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => notifier.clear(),
            tooltip: 'Clear',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: Icon(Icons.search, size: 20),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onChanged: (value) => notifier.setSearchQuery(value),
            ),
          ),
          const SizedBox(width: 16),
          _buildLevelFilter(ref, state, LogLevel.verbose, 'V', Colors.grey),
          _buildLevelFilter(ref, state, LogLevel.debug, 'D', Colors.blue),
          _buildLevelFilter(ref, state, LogLevel.info, 'I', Colors.green),
          _buildLevelFilter(ref, state, LogLevel.warning, 'W', Colors.orange),
          _buildLevelFilter(ref, state, LogLevel.error, 'E', Colors.red),
        ],
      ),
    );
  }

  Widget _buildLevelFilter(WidgetRef ref, LogcatState state, LogLevel level, String label, Color color) {
    final isActive = state.activeLevels.contains(level);
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        onTap: () => ref.read(logcatNotifierProvider.notifier).toggleLevel(level),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(color: isActive ? color : Colors.white10),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? color : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
