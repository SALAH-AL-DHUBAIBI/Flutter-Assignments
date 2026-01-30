import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());
    
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          const Padding(
             padding: EdgeInsets.all(16.0),
             child: Text("Default App Configuration (Required)", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.dialpad, color: Colors.blue),
            title: const Text("Set as Default Phone App"),
            subtitle: const Text("Required for calling features"),
            onTap: controller.requestDefaultDialerRole,
          ),
          ListTile(
            leading: const Icon(Icons.message, color: Colors.green),
            title: const Text("Set as Default SMS App"),
            subtitle: const Text("Required for SMS features"),
            onTap: controller.requestDefaultSmsRole,
          ),
          const Divider(),
          const Padding(
             padding: EdgeInsets.all(16.0),
             child: Text("Permissions", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text("Request All Permissions"),
            leading: const Icon(Icons.lock_open),
            onTap: controller.requestAllPermissions,
          )
        ],
      ),
    );
  }
}
