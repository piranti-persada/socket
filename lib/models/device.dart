import 'device_status.dart';

class BatteryInfo {
  final int level;
  final bool isCharging;
  final double temperature;
  final String health;

  BatteryInfo({
    required this.level,
    required this.isCharging,
    required this.temperature,
    required this.health,
  });
}

class StorageInfo {
  final int totalBytes;
  final int usedBytes;
  final int freeBytes;

  StorageInfo({
    required this.totalBytes,
    required this.usedBytes,
    required this.freeBytes,
  });

  double get percentageUsed => totalBytes > 0 ? usedBytes / totalBytes : 0;
}

enum DeviceConnectionType { usb, wifi, emulator, unknown }

class Device {
  final String serial;
  final String model;
  final String manufacturer;
  final String androidVersion;
  final int sdkVersion;
  final String buildNumber;
  final DeviceStatus status;
  final DeviceConnectionType connectionType;
  final BatteryInfo? battery;
  final StorageInfo? storage;

  Device({
    required this.serial,
    required this.model,
    required this.manufacturer,
    required this.androidVersion,
    required this.sdkVersion,
    required this.buildNumber,
    required this.status,
    required this.connectionType,
    this.battery,
    this.storage,
  });

  Device copyWith({
    String? serial,
    String? model,
    String? manufacturer,
    String? androidVersion,
    int? sdkVersion,
    String? buildNumber,
    DeviceStatus? status,
    DeviceConnectionType? connectionType,
    BatteryInfo? battery,
    StorageInfo? storage,
  }) {
    return Device(
      serial: serial ?? this.serial,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      androidVersion: androidVersion ?? this.androidVersion,
      sdkVersion: sdkVersion ?? this.sdkVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      status: status ?? this.status,
      connectionType: connectionType ?? this.connectionType,
      battery: battery ?? this.battery,
      storage: storage ?? this.storage,
    );
  }
}
