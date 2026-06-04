import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../providers/command_palette_providers.dart';
import '../core/theme/app_colors.dart';

class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => const CommandPalette(),
    );
  }

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event, int itemCount) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % itemCount;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1 + itemCount) % itemCount;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        _executeSelected(itemCount);
      }
    }
  }

  void _executeSelected(int itemCount) {
    if (itemCount == 0) return;
    final actions = ref.read(filteredCommandActionsProvider);
    if (_selectedIndex >= 0 && _selectedIndex < actions.length) {
      final action = actions[_selectedIndex];
      Navigator.of(context).pop();
      action.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = ref.watch(filteredCommandActionsProvider);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) => _handleKeyEvent(event, actions.length),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: 600,
              constraints: const BoxConstraints(maxHeight: 500),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Search commands...',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                      onChanged: (value) {
                        ref.read(commandSearchQueryProvider.notifier).state = value;
                        setState(() {
                          _selectedIndex = 0;
                        });
                      },
                      onSubmitted: (_) => _executeSelected(actions.length),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: actions.length,
                      itemBuilder: (context, index) {
                        final action = actions[index];
                        final isSelected = index == _selectedIndex;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                              _executeSelected(actions.length);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
                              child: Row(
                                children: [
                                  Icon(action.icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          action.title,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        if (action.subtitle != null)
                                          Text(
                                            action.subtitle!,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary.withOpacity(0.7),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      action.category,
                                      style: const TextStyle(fontSize: 10, color: Colors.white54),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
