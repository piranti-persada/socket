import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_providers.dart';
import '../providers/media_providers.dart';
import '../widgets/empty_state.dart';
import 'package:file_picker/file_picker.dart';

class ScreenshotScreen extends ConsumerWidget {
  const ScreenshotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(selectedDeviceProvider);
    final screenshot = ref.watch(screenshotProvider);
    final isTaking = ref.watch(isTakingScreenshotProvider);

    if (device == null) {
      return const EmptyState(
        icon: Icons.camera_alt,
        title: 'Screenshot',
        message: 'Select a device to capture screenshots.',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Screenshot', style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: isTaking ? null : () async {
                  ref.read(isTakingScreenshotProvider.notifier).state = true;
                  final service = ref.read(screenshotServiceProvider);
                  final bytes = await service.capture(device.serial);
                  ref.read(screenshotProvider.notifier).state = bytes;
                  ref.read(isTakingScreenshotProvider.notifier).state = false;
                },
                icon: isTaking 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.camera),
                label: const Text('Capture'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: screenshot == null
                ? const Center(child: Text('No screenshot captured yet.'))
                : Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              screenshot,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 200,
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final path = await FilePicker.platform.saveFile(
                                    dialogTitle: 'Save Screenshot',
                                    fileName: 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png',
                                    type: FileType.image,
                                  );
                                  if (path != null) {
                                    await ref.read(screenshotServiceProvider).saveTo(screenshot, path);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Saved to $path')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.save),
                                label: const Text('Save to File'),
                              ),
                            ),
                            // Copy to clipboard not implemented due to lack of standard package in initial setup
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
