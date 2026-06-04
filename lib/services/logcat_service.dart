import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../core/constants/app_constants.dart';
import '../core/utils/process_runner.dart';
import '../models/logcat_entry.dart';

class LogcatService {
  Process? _process;

  Stream<LogcatEntry> startStream(String serial) async* {
    stopStream();
    
    // Clear first
    await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'logcat', '-c']);
    
    _process = await ProcessRunner.start(AppConstants.adbPath, ['-s', serial, 'logcat', '-v', 'threadtime']);
    
    if (_process != null) {
      yield* _process!.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .map((line) => LogcatEntry.parse(line));
    }
  }

  void stopStream() {
    _process?.kill();
    _process = null;
  }
}
