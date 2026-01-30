import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/history_controller.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Icon _getIcon(String type) {
    // Type 1 = Incoming, 2 = Outgoing, 3 = Missed
    switch (type) {
      case '1': return const Icon(Icons.call_received, color: Colors.blue);
      case '2': return const Icon(Icons.call_made, color: Colors.green);
      case '3': return const Icon(Icons.call_missed, color: Colors.red);
      default: return const Icon(Icons.call, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.put(HistoryController());
    
    return Scaffold(
      appBar: AppBar(title: const Text("Call History")),
      body: Obx(() => controller.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () async => controller.fetchLogs(),
            child: ListView.builder(
              itemCount: controller.logs.length,
              itemBuilder: (context, index) {
                final log = controller.logs[index];
                return ListTile(
                  leading: _getIcon(log['type'] ?? ''),
                  title: Text(log['name'] != null && log['name'].isNotEmpty ? log['name'] : (log['number'] ?? 'Unknown'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(controller.formatDate(log['date']) + (log['name'] != null && log['name'].isNotEmpty ? " (${log['number']})" : "")),
                  trailing: IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () => NativeService.makeDirectCall(log['number']),
                  ),
                );
              },
            ),
          )
      ),
    );
  }
}
