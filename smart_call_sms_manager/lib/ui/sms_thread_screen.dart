import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/sms_thread_controller.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';


class SmsThreadScreen extends StatelessWidget {
  final String address;
  final String? threadId;
  final String? name;
  final Function? onMessagesRead;

  const SmsThreadScreen({
    super.key,
    required this.address,
    this.threadId,
    this.name,
    this.onMessagesRead,
  });

  Future<void> _schedule(
    BuildContext context,
    SmsThreadController controller,
    String msg,
  ) async {
    if (msg.isEmpty) {
      Get.snackbar('Error', 'Enter message first');
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    if (!context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    if (!context.mounted) return;

    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    try {

      await NativeService.scheduleSms(address, msg, scheduledAt);
      Get.snackbar('Success', 'Message scheduled!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to schedule: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      SmsThreadController(
        address: address,
        threadId: threadId,
        initialName: name,
        onMessagesRead: onMessagesRead,
      ),
    );
    final textController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.contactName ?? address),
              if (controller.contactName != null)
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => NativeService.makeDirectCall(address),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.message, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No messages yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => controller.loadData(),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.messages.length,
                reverse: false,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMe = msg['type'] == '2';
                  final date = msg['date'] != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                          int.parse(msg['date']),
                        )
                      : DateTime.now();

                  return Column(
                    children: [
                      if (index == 0 ||
                          _shouldShowDate(
                            controller.messages[index - 1]['date'],
                            msg['date'],
                          ))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            _formatMessageDate(date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['body'] ?? '',
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(date),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isMe
                                      ? Colors.white70
                                      : Colors.grey[600],
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
          Obx(
            () => controller.isSending
                ? const LinearProgressIndicator()
                : const SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: "Text message (Hold send to schedule)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onLongPress: () =>
                      _schedule(context, controller, textController.text),
                  onTap: () async {
                    if (textController.text.isNotEmpty) {
                      await controller.sendMessage(textController.text);
                      textController.clear();
                    }
                  },
                  child: Obx(
                    () => CircleAvatar(
                      backgroundColor: controller.isSending
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      child: controller.isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDate(String? prevDate, String? currentDate) {
    if (prevDate == null || currentDate == null) return false;

    final prev = DateTime.fromMillisecondsSinceEpoch(int.parse(prevDate));
    final current = DateTime.fromMillisecondsSinceEpoch(int.parse(currentDate));

    return prev.day != current.day ||
        prev.month != current.month ||
        prev.year != current.year;
  }

  String _formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
