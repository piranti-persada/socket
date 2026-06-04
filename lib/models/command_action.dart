import 'package:flutter/material.dart';

class CommandAction {
  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final String category;
  final String? shortcut;
  final Future<void> Function() execute;

  const CommandAction({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.category,
    this.shortcut,
    required this.execute,
  });
}
