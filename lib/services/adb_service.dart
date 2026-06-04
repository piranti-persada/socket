import '../core/constants/app_constants.dart';
import '../core/utils/process_runner.dart';
import '../models/device.dart';
import '../models/device_status.dart';

class AdbService {
  Future<List<Device>> getDevices() async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['devices', '-l']);
    if (!result.isSuccess) {
      return [];
    }

    final lines = result.stdout.split('\n');
    final devices = <Device>[];

    for (final line in lines) {
      if (line.trim().isEmpty || line.startsWith('List of devices attached')) {
        continue;
      }

      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        final serial = parts[0];
        final statusStr = parts[1];
        
        DeviceStatus status;
        switch (statusStr) {
          case 'device':
            status = DeviceStatus.connected;
            break;
          case 'unauthorized':
            status = DeviceStatus.unauthorized;
            break;
          case 'offline':
            status = DeviceStatus.offline;
            break;
          case 'fastboot':
            status = DeviceStatus.fastboot;
            break;
          default:
            status = DeviceStatus.unknown;
        }

        String model = 'Unknown Model';
        DeviceConnectionType connectionType = DeviceConnectionType.usb;
        
        if (serial.contains(':5555')) {
          connectionType = DeviceConnectionType.wifi;
        } else if (serial.startsWith('emulator-')) {
          connectionType = DeviceConnectionType.emulator;
        }

        for (int i = 2; i < parts.length; i++) {
          if (parts[i].startsWith('model:')) {
            model = parts[i].substring(6).replaceAll('_', ' ');
          }
        }

        devices.add(Device(
          serial: serial,
          model: model,
          manufacturer: 'Unknown',
          androidVersion: 'Unknown',
          sdkVersion: 0,
          buildNumber: 'Unknown',
          status: status,
          connectionType: connectionType,
        ));
      }
    }

    return devices;
  }

  Future<String?> getDeviceProperty(String serial, String property) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'shell', 'getprop', property]);
    if (result.isSuccess) {
      return result.stdout.trim();
    }
    return null;
  }

  Future<BatteryInfo?> getBatteryInfo(String serial) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'shell', 'dumpsys', 'battery']);
    if (!result.isSuccess) return null;

    final lines = result.stdout.split('\n');
    int level = 0;
    bool isCharging = false;
    double temperature = 0.0;
    String health = 'Unknown';

    for (final line in lines) {
      final p = line.trim();
      if (p.startsWith('level:')) {
        level = int.tryParse(p.split(':')[1].trim()) ?? 0;
      } else if (p.startsWith('status:')) {
        final status = int.tryParse(p.split(':')[1].trim()) ?? 1;
        isCharging = (status == 2);
      } else if (p.startsWith('temperature:')) {
        final temp = int.tryParse(p.split(':')[1].trim()) ?? 0;
        temperature = temp / 10.0;
      } else if (p.startsWith('health:')) {
        final h = int.tryParse(p.split(':')[1].trim()) ?? 1;
        health = _getBatteryHealth(h);
      }
    }

    return BatteryInfo(
      level: level,
      isCharging: isCharging,
      temperature: temperature,
      health: health,
    );
  }

  String _getBatteryHealth(int healthCode) {
    switch (healthCode) {
      case 2: return 'Good';
      case 3: return 'Overheat';
      case 4: return 'Dead';
      case 5: return 'Over voltage';
      case 6: return 'Unspecified failure';
      case 7: return 'Cold';
      default: return 'Unknown';
    }
  }

  Future<StorageInfo?> getStorageInfo(String serial) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'shell', 'df', '/data']);
    if (!result.isSuccess) return null;

    final lines = result.stdout.split('\n');
    if (lines.length > 1) {
      final parts = lines[1].trim().split(RegExp(r'\s+'));
      if (parts.length >= 6) {
        // df output format varies, but usually:
        // Filesystem 1K-blocks Used Available Use% Mounted on
        final total = (int.tryParse(parts[1]) ?? 0) * 1024;
        final used = (int.tryParse(parts[2]) ?? 0) * 1024;
        final available = (int.tryParse(parts[3]) ?? 0) * 1024;
        
        return StorageInfo(
          totalBytes: total,
          usedBytes: used,
          freeBytes: available,
        );
      }
    }
    return null;
  }
}
