import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          _buildSettingsSection(
            context,
            'ADB Configuration',
            [
              ListTile(
                title: const Text('ADB Path'),
                subtitle: const Text('Auto-detect (System PATH)'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Change'),
                ),
              ),
              ListTile(
                title: const Text('Device Polling Interval'),
                subtitle: const Text('3 seconds'),
                trailing: const Icon(Icons.timer),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            context,
            'Appearance',
            [
              ListTile(
                title: const Text('Theme'),
                subtitle: const Text('Dark Mode (Default)'),
                trailing: const Icon(Icons.dark_mode),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}
