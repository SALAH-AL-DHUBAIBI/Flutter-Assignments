import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/history_controller.dart';
import 'package:smart_call_sms_manager/ui/call_logs_screen.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Icon _getIcon(String type) {
    // Type 1 = Incoming, 2 = Outgoing, 3 = Missed
    switch (type) {
      case '1':
        return const Icon(Icons.call_received, color: Colors.blue);
      case '2':
        return const Icon(Icons.call_made, color: Colors.green);
      case '3':
        return const Icon(Icons.call_missed, color: Colors.red);
      default:
        return const Icon(Icons.call, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.put(HistoryController());

    return Scaffold(
      appBar: AppBar(title: const Text('Call History')),
      body: Obx(() {
        if (controller.isLoading)
          return const Center(child: CircularProgressIndicator());

        final groups = controller.groupedLogs;

        if (groups.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchLogs,
            child: ListView(
              children: const [
                SizedBox(height: 200),
                Center(child: Text('No history found')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLogs,
          child: ListView.separated(
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final g = groups[index];
              final number = g['number'] ?? '';
              final name = g['name'];
              final count = g['count'] ?? 1;
              final totalDuration = g['totalDuration'] ?? 0;
              final type = g['type'] ?? '2';
              final date = g['date'];

              final displayName = (name is String && name.isNotEmpty)
                  ? name
                  : (number.isNotEmpty ? number : 'Unknown');

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: _getIcon(type),
                ),
                title: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${controller.formatDate(date)} • ${count} call${count > 1 ? 's' : ''} • ${totalDuration}s',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () => NativeService.makeDirectCall(number),
                ),
                onTap: () => Get.to(() => CallLogsScreen(number: number)),
              );
            },
          ),
        );
      }),
    );
  }
}
