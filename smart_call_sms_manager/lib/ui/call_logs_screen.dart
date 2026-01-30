import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/history_controller.dart';
import 'package:smart_call_sms_manager/ui/sms_thread_screen.dart';
import 'package:smart_call_sms_manager/services/native_service.dart' as ns;

class CallLogsScreen extends StatelessWidget {
  final String number;
  const CallLogsScreen({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.find();
    final logs = controller.getLogsForNumber(number);
    final first = logs.isNotEmpty ? logs.first : null;
    final displayName =
        first != null &&
            first['name'] is String &&
            (first['name'] as String).isNotEmpty
        ? first['name'] as String
        : number;

    Icon typeIcon(String? type) {
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

    String formatDuration(int seconds) {
      if (seconds <= 0) return '0s';
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      final s = seconds % 60;
      if (h > 0) return '${h}h ${m}m ${s}s';
      if (m > 0) return '${m}m ${s}s';
      return '${s}s';
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(displayName),
            if (number.isNotEmpty)
              Text(number, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Message',
            icon: const Icon(Icons.message),
            onPressed: () => Get.to(() => SmsThreadScreen(address: number)),
          ),
          IconButton(
            tooltip: 'Call',
            icon: const Icon(Icons.call),
            onPressed: () => ns.NativeService.makeDirectCall(number),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final dateStr = controller.formatDate(log['date']);
          final duration =
              int.tryParse((log['duration'] ?? '0').toString()) ?? 0;
          final type = log['type']?.toString();
          return ListTile(
            leading: typeIcon(type),
            title: Text(
              log['name'] != null && (log['name'] as String).isNotEmpty
                  ? log['name']
                  : number,
            ),
            subtitle: Text('$dateStr • ${formatDuration(duration)}'),
            trailing: IconButton(
              icon: const Icon(Icons.call),
              onPressed: () => ns.NativeService.makeDirectCall(number),
            ),
          );
        },
      ),
    );
  }
}
