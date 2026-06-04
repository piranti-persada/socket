import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../widgets/device_list_panel.dart';
import '../widgets/command_palette.dart';
import 'dashboard_screen.dart';
import 'logcat_screen.dart';
import 'packages_screen.dart';
import 'screenshot_screen.dart';
import 'screen_record_screen.dart';
import 'apk_install_screen.dart';
import 'wireless_setup_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HotKey _commandPaletteKey = HotKey(
    KeyCode.keyK,
    modifiers: [KeyModifier.control],
    scope: HotKeyScope.inapp,
  );
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    hotKeyManager.register(
      _commandPaletteKey,
      keyDownHandler: (hotKey) {
        CommandPalette.show(context);
      },
    );
  }

  @override
  void dispose() {
    hotKeyManager.unregister(_commandPaletteKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_selectedIndex) {
      case 0:
        content = const DashboardScreen();
        break;
      case 1:
        content = const LogcatScreen();
        break;
      case 2:
        content = const PackagesScreen();
        break;
      case 3:
        content = const ScreenshotScreen();
        break;
      case 4:
        content = const ScreenRecordScreen();
        break;
      case 5:
        content = const ApkInstallScreen();
        break;
      case 6:
        content = const WirelessSetupScreen();
        break;
      case 7:
        content = const SettingsScreen();
        break;
      default:
        content = const DashboardScreen();
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.none,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('Logcat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.apps_outlined),
                selectedIcon: Icon(Icons.apps),
                label: Text('Packages'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.camera_alt_outlined),
                selectedIcon: Icon(Icons.camera_alt),
                label: Text('Screenshot'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.videocam_outlined),
                selectedIcon: Icon(Icons.videocam),
                label: Text('Record'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.install_mobile_outlined),
                selectedIcon: Icon(Icons.install_mobile),
                label: Text('Install APK'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.wifi_outlined),
                selectedIcon: Icon(Icons.wifi),
                label: Text('Wireless'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          const DeviceListPanel(),
          Expanded(child: content),
        ],
      ),
    );
  }
}
