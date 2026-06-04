import '../core/constants/app_constants.dart';
import '../core/utils/process_runner.dart';

class WirelessService {
  Future<String?> getDeviceIp(String serial) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'shell', 'ip', 'route']);
    if (!result.isSuccess) return null;

    final lines = result.stdout.split('\n');
    for (final line in lines) {
      if (line.contains('wlan0')) {
        final parts = line.split(RegExp(r'\s+'));
        for (int i = 0; i < parts.length; i++) {
          if (parts[i] == 'src' && i + 1 < parts.length) {
            return parts[i + 1];
          }
        }
      }
    }
    return null;
  }

  Future<bool> enableTcpip(String serial, {int port = 5555}) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['-s', serial, 'tcpip', port.toString()]);
    return result.isSuccess;
  }

  Future<bool> connect(String ip, {int port = 5555}) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['connect', '$ip:$port']);
    return result.stdout.contains('connected');
  }

  Future<bool> pair(String ip, int port, String code) async {
    // Note: requires adb pair to be interactive or passed exactly, varying by ADB version.
    // Basic implementation:
    final result = await ProcessRunner.run(AppConstants.adbPath, ['pair', '$ip:$port', code]);
    return result.stdout.contains('Successfully paired');
  }

  Future<bool> disconnect(String ip, {int port = 5555}) async {
    final result = await ProcessRunner.run(AppConstants.adbPath, ['disconnect', '$ip:$port']);
    return result.isSuccess;
  }
}
