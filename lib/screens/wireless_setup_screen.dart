import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_providers.dart';
import '../services/wireless_service.dart';
import '../core/theme/app_colors.dart';
import '../widgets/empty_state.dart';

final wirelessServiceProvider = Provider((ref) => WirelessService());

class WirelessSetupScreen extends ConsumerStatefulWidget {
  const WirelessSetupScreen({super.key});

  @override
  ConsumerState<WirelessSetupScreen> createState() => _WirelessSetupScreenState();
}

class _WirelessSetupScreenState extends ConsumerState<WirelessSetupScreen> {
  int _currentStep = 0;
  String _ipAddress = '';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final device = ref.watch(selectedDeviceProvider);

    if (device == null) {
      return const EmptyState(
        icon: Icons.wifi,
        title: 'Wireless Setup',
        message: 'Connect a device via USB first to set up wireless debugging.',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wireless Debugging Setup', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 32),
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: () async {
                if (_currentStep == 0) { // Enable TCP/IP
                  setState(() => _isProcessing = true);
                  await ref.read(wirelessServiceProvider).enableTcpip(device.serial);
                  
                  // Wait a bit, then get IP
                  await Future.delayed(const Duration(seconds: 2));
                  final ip = await ref.read(wirelessServiceProvider).getDeviceIp(device.serial);
                  
                  setState(() {
                    _ipAddress = ip ?? 'Unknown (Check Wi-Fi settings)';
                    _isProcessing = false;
                    _currentStep++;
                  });
                } else if (_currentStep == 1) { // Connect
                  setState(() => _isProcessing = true);
                  if (_ipAddress != 'Unknown (Check Wi-Fi settings)') {
                    await ref.read(wirelessServiceProvider).connect(_ipAddress);
                  }
                  setState(() {
                    _isProcessing = false;
                    _currentStep++;
                  });
                } else if (_currentStep == 2) { // Done
                  // Reset or handle done
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() {
                    _currentStep--;
                  });
                }
              },
              steps: [
                Step(
                  title: const Text('Enable TCP/IP'),
                  content: const Text('This will restart the ADB daemon on the device in TCP/IP mode on port 5555.'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Detect IP & Connect'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detected IP: $_ipAddress'),
                      const SizedBox(height: 8),
                      const Text('Make sure your PC and device are on the same network. Click continue to connect.'),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Complete'),
                  content: const Text('Wireless debugging is now active. You can safely disconnect the USB cable.'),
                  isActive: _currentStep >= 2,
                  state: _currentStep == 2 ? StepState.complete : StepState.indexed,
                ),
              ],
              controlsBuilder: (context, details) {
                if (_currentStep == 2) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: () => setState(() => _currentStep = 0),
                      child: const Text('Reset'),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isProcessing ? null : details.onStepContinue,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                        child: _isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Continue'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _isProcessing ? null : details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
