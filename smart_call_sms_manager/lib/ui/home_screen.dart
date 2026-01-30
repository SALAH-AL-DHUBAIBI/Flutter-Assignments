import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/home_controller.dart';
import 'package:smart_call_sms_manager/ui/dialer_screen.dart';
import 'package:smart_call_sms_manager/ui/sms_list_screen.dart';
import 'package:smart_call_sms_manager/ui/history_screen.dart';
import 'package:smart_call_sms_manager/ui/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    final List<Widget> screens = [
      const DialerScreen(),
      const SmsListScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Obx(() => screens[controller.selectedIndex]),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.selectedIndex,
          onDestinationSelected: controller.changeTab,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dialpad), label: 'Phone'),
            NavigationDestination(icon: Icon(Icons.message), label: 'SMS'),
            NavigationDestination(icon: Icon(Icons.history), label: 'History'),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}


