import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/device_providers.dart';
import '../services/adb_service.dart';
import '../widgets/empty_state.dart';
import '../core/theme/app_colors.dart';

final apkInstallStateProvider = StateProvider<String?>((ref) => null);

class ApkInstallScreen extends ConsumerWidget {
  const ApkInstallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(selectedDeviceProvider);
    final installStatus = ref.watch(apkInstallStateProvider);

    if (device == null) {
      return const EmptyState(
        icon: Icons.install_mobile,
        title: 'Install APK',
        message: 'Select a device to install applications.',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Install APK', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          Expanded(
            child: DropTarget(
              onDragDone: (details) async {
                if (details.files.isNotEmpty) {
                  final file = details.files.first;
                  if (file.path.endsWith('.apk')) {
                    _installApk(ref, device.serial, file.path);
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: Colors.white24, style: BorderStyle.solid, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file, size: 80, color: AppColors.primary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text('Drag and drop APK file here', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('or', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['apk'],
                          );
                          if (result != null && result.files.single.path != null) {
                            _installApk(ref, device.serial, result.files.single.path!);
                          }
                        },
                        child: const Text('Browse Files'),
                      ),
                      if (installStatus != null) ...[
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(installStatus),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _installApk(WidgetRef ref, String serial, String path) async {
    ref.read(apkInstallStateProvider.notifier).state = 'Installing $path...';
    
    // In a real app we would stream the output, but for now we'll just await the ProcessRunner
    // using the AdbService.
    final adb = ref.read(adbServiceProvider);
    
    // Using ProcessRunner directly to pass specific args
    import '../core/utils/process_runner.dart';
    import '../core/constants/app_constants.dart';
    
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'install', '-r', path]);
    
    if (result.isSuccess) {
      ref.read(apkInstallStateProvider.notifier).state = 'Success: ${result.stdout}';
    } else {
      ref.read(apkInstallStateProvider.notifier).state = 'Error: ${result.stderr}';
    }
  }
}
