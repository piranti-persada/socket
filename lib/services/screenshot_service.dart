import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/process_runner.dart';

class ScreenshotService {
  Future<Uint8List?> capture(String serial) async {
    try {
      final process = await Process.start(AppConstants.adbPath, ['-s', serial, 'exec-out', 'screencap', '-p']);
      final bytes = <int>[];
      await for (var chunk in process.stdout) {
        bytes.addAll(chunk);
      }
      final exitCode = await process.exitCode;
      if (exitCode == 0 && bytes.isNotEmpty) {
        return Uint8List.fromList(bytes);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> saveTo(Uint8List bytes, String path) async {
    try {
      final file = File(path);
      await file.writeAsBytes(bytes);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Not implementing cross-platform clipboard here since flutter/services Clipboard only supports text.
  // We would need a plugin like pasteboard or super_clipboard to put images on the clipboard.
}
