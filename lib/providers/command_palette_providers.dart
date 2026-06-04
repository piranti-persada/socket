import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/command_action.dart';

final commandActionsProvider = Provider<List<CommandAction>>((ref) {
  // Placeholder actions for now
  return [
    CommandAction(
      id: 'take_screenshot',
      title: 'Take Screenshot',
      icon: Icons.camera_alt,
      category: 'Tools',
      execute: () async {
        debugPrint('Taking screenshot');
      },
    ),
    CommandAction(
      id: 'open_logcat',
      title: 'Open Logcat',
      icon: Icons.receipt_long,
      category: 'Tools',
      execute: () async {
        debugPrint('Opening logcat');
      },
    ),
    CommandAction(
      id: 'reboot_device',
      title: 'Restart Device',
      icon: Icons.restart_alt,
      category: 'Device',
      execute: () async {
        debugPrint('Restarting device');
      },
    ),
    CommandAction(
      id: 'open_settings',
      title: 'Open Settings',
      icon: Icons.settings,
      category: 'System',
      execute: () async {
        debugPrint('Opening settings');
      },
    ),
  ];
});

final commandSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredCommandActionsProvider = Provider<List<CommandAction>>((ref) {
  final query = ref.watch(commandSearchQueryProvider).toLowerCase();
  final actions = ref.watch(commandActionsProvider);

  if (query.isEmpty) return actions;

  return actions.where((action) {
    return action.title.toLowerCase().contains(query) ||
           action.category.toLowerCase().contains(query);
  }).toList();
});
