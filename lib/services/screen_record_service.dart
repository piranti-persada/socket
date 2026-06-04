import 'dart:async';
import 'dart:io';
import '../core/constants/app_constants.dart';
import '../core/utils/process_runner.dart';

enum RecordingState { idle, recording, pulling }

class ScreenRecordService {
  Process? _process;

  Future<bool> startRecording(String serial, {String remotePath = '/sdcard/screenrecord.mp4'}) async {
    if (_process != null) return false;
    
    try {
      _process = await Process.start(AppConstants.adbPath, ['-s', serial, 'shell', 'screenrecord', remotePath]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopRecording() async {
    if (_process != null) {
      // Sending Ctrl+C equivalent to stop screenrecord cleanly
      _process!.kill(ProcessSignal.sigint);
      // Wait a bit for it to finalize the mp4
      await Future.delayed(const Duration(seconds: 1));
      _process = null;
    }
  }

  Future<bool> pullRecording(String serial, String remotePath, String localPath) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'pull', remotePath, localPath]);
    return result.isSuccess;
  }
}
