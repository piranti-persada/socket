import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/device.dart';
import '../services/adb_service.dart';
import '../services/device_manager.dart';

final adbServiceProvider = Provider<AdbService>((ref) {
  return AdbService();
});

final deviceManagerProvider = Provider<DeviceManager>((ref) {
  final adbService = ref.watch(adbServiceProvider);
  return DeviceManager(adbService);
});

final deviceListProvider = StateNotifierProvider<DeviceListNotifier, AsyncValue<List<Device>>>((ref) {
  final manager = ref.watch(deviceManagerProvider);
  return DeviceListNotifier(manager);
});

class DeviceListNotifier extends StateNotifier<AsyncValue<List<Device>>> {
  final DeviceManager _manager;
  Timer? _timer;

  DeviceListNotifier(this._manager) : super(const AsyncValue.loading()) {
    _startPolling();
  }

  void _startPolling() {
    _fetchDevices();
    _timer = Timer.periodic(AppConstants.devicePollInterval, (_) {
      _fetchDevices();
    });
  }

  Future<void> _fetchDevices() async {
    try {
      final devices = await _manager.fetchDevices();
      if (mounted) {
        state = AsyncValue.data(devices);
      }
    } catch (e, st) {
      if (mounted && !state.hasValue) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final selectedDeviceProvider = StateProvider<Device?>((ref) {
  return null;
});
