import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device.dart';
import '../models/device_status.dart';
import 'adb_service.dart';

class DeviceManager {
  final AdbService _adbService;
  Timer? _pollingTimer;
  
  DeviceManager(this._adbService);

  Future<List<Device>> fetchDevices() async {
    final devices = await _adbService.getDevices();
    
    // Enrich connected devices with properties
    final enrichedDevices = await Future.wait(devices.map((device) async {
      if (device.status == DeviceStatus.connected) {
        final manufacturer = await _adbService.getDeviceProperty(device.serial, 'ro.product.manufacturer') ?? 'Unknown';
        final actualModel = await _adbService.getDeviceProperty(device.serial, 'ro.product.model') ?? device.model;
        final androidVersion = await _adbService.getDeviceProperty(device.serial, 'ro.build.version.release') ?? 'Unknown';
        final sdkVersionStr = await _adbService.getDeviceProperty(device.serial, 'ro.build.version.sdk');
        final buildNumber = await _adbService.getDeviceProperty(device.serial, 'ro.build.display.id') ?? 'Unknown';
        
        final battery = await _adbService.getBatteryInfo(device.serial);
        final storage = await _adbService.getStorageInfo(device.serial);

        return device.copyWith(
          manufacturer: manufacturer,
          model: actualModel,
          androidVersion: androidVersion,
          sdkVersion: int.tryParse(sdkVersionStr ?? '') ?? 0,
          buildNumber: buildNumber,
          battery: battery,
          storage: storage,
        );
      }
      return device;
    }));
    
    return enrichedDevices;
  }
}
