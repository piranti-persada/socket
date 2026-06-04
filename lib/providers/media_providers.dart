import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/screenshot_service.dart';
import '../services/screen_record_service.dart';

final screenshotServiceProvider = Provider((ref) => ScreenshotService());
final screenRecordServiceProvider = Provider((ref) => ScreenRecordService());

final screenshotProvider = StateProvider<Uint8List?>((ref) => null);
final isTakingScreenshotProvider = StateProvider<bool>((ref) => false);

final recordingStateProvider = StateProvider<RecordingState>((ref) => RecordingState.idle);
final recordingTimerProvider = StateProvider<int>((ref) => 0);
