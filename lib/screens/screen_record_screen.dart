import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/device_providers.dart';
import '../providers/media_providers.dart';
import '../services/screen_record_service.dart';
import '../widgets/empty_state.dart';
import '../core/theme/app_colors.dart';

class ScreenRecordScreen extends ConsumerWidget {
  const ScreenRecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(selectedDeviceProvider);
    final state = ref.watch(recordingStateProvider);
    final timer = ref.watch(recordingTimerProvider);

    if (device == null) {
      return const EmptyState(
        icon: Icons.videocam,
        title: 'Screen Record',
        message: 'Select a device to record the screen.',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Screen Record', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                if (state == RecordingState.idle)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      ref.read(recordingStateProvider.notifier).state = RecordingState.recording;
                      final service = ref.read(screenRecordServiceProvider);
                      final success = await service.startRecording(device.serial);
                      if (success) {
                        int ticks = 0;
                        Timer.periodic(const Duration(seconds: 1), (t) {
                          if (ref.read(recordingStateProvider) != RecordingState.recording) {
                            t.cancel();
                            return;
                          }
                          ticks++;
                          ref.read(recordingTimerProvider.notifier).state = ticks;
                        });
                      } else {
                        ref.read(recordingStateProvider.notifier).state = RecordingState.idle;
                      }
                    },
                    icon: const Icon(Icons.fiber_manual_record, color: AppColors.error, size: 32),
                    label: const Text('Start Recording', style: TextStyle(fontSize: 18)),
                  )
                else if (state == RecordingState.recording)
                  Column(
                    children: [
                      Text(
                        '${(timer ~/ 60).toString().padLeft(2, '0')}:${(timer % 60).toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final service = ref.read(screenRecordServiceProvider);
                          await service.stopRecording();
                          ref.read(recordingStateProvider.notifier).state = RecordingState.pulling;
                          
                          final path = await FilePicker.platform.saveFile(
                            dialogTitle: 'Save Screen Recording',
                            fileName: 'recording_${DateTime.now().millisecondsSinceEpoch}.mp4',
                            type: FileType.video,
                          );

                          if (path != null && context.mounted) {
                            await service.pullRecording(device.serial, '/sdcard/screenrecord.mp4', path);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Saved to $path')),
                            );
                          }
                          
                          ref.read(recordingStateProvider.notifier).state = RecordingState.idle;
                          ref.read(recordingTimerProvider.notifier).state = 0;
                        },
                        icon: const Icon(Icons.stop, size: 32),
                        label: const Text('Stop & Save', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  )
                else if (state == RecordingState.pulling)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Saving video...'),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
