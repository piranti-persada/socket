import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_providers.dart';
import '../providers/logcat_providers.dart';
import '../widgets/empty_state.dart';
import '../widgets/logcat_entry_tile.dart';
import '../widgets/logcat_filter_bar.dart';
import '../core/theme/app_colors.dart';

class LogcatScreen extends ConsumerStatefulWidget {
  const LogcatScreen({super.key});

  @override
  ConsumerState<LogcatScreen> createState() => _LogcatScreenState();
}

class _LogcatScreenState extends ConsumerState<LogcatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.position.pixels;
        // If user scrolls up, disable auto-scroll
        setState(() {
          _autoScroll = maxScroll - currentScroll <= 50;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDevice = ref.watch(selectedDeviceProvider);
    final entries = ref.watch(filteredLogcatProvider);

    if (selectedDevice == null) {
      return const EmptyState(
        icon: Icons.receipt_long,
        title: 'Logcat',
        message: 'Select a device to view logs.',
      );
    }

    if (_autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }

    return Column(
      children: [
        const LogcatFilterBar(),
        Expanded(
          child: Container(
            color: AppColors.background,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return LogcatEntryTile(entry: entries[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
}
