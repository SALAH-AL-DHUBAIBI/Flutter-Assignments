import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/sms_controller.dart';
import 'package:smart_call_sms_manager/ui/sms_compose_screen.dart';
import 'package:smart_call_sms_manager/ui/sms_thread_screen.dart';

class SmsListScreen extends StatelessWidget {
  const SmsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SmsController controller = Get.put(SmsController());
    
    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: Obx(() => controller.isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: controller.fetchSms,
            child: ListView.builder(
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final thread = controller.messages[index];
                final address = thread['address'] ?? 'Unknown';
                final displayName = thread['name'] ?? address;
                final unreadCount = int.tryParse(thread['unread_count'] ?? '0') ?? 0;
                final hasUnread = unreadCount > 0;
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: hasUnread ? Colors.blue : Colors.grey,
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?', 
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                        ),
                      ),
                      // Unread indicator dot
                      if (hasUnread)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName, 
                          style: TextStyle(
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        controller.formatDate(thread['date']), 
                        style: TextStyle(
                          fontSize: 12, 
                          color: hasUnread ? Colors.blue : Colors.grey,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                        )
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread['snippet'] ?? '', 
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                            color: hasUnread ? Colors.black87 : Colors.grey[600],
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () async {
                    // Navigate to thread
                    await Get.to(() => SmsThreadScreen(
                      address: address, 
                      threadId: thread['thread_id'], // Pass thread_id
                      name: thread['name'],
                      onMessagesRead: () {
                        // Refresh list immediately when messages are marked as read
                        Future.delayed(const Duration(milliseconds: 500), () {
                          controller.fetchSms(silent: true);
                        });
                      },
                    ));
                    // Also refresh when returning
                    controller.fetchSms(silent: true);
                  },
                );
              },
            ),
          )
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () => Get.to(() => const SmsComposeScreen()),
      ),
    );
  }
}
