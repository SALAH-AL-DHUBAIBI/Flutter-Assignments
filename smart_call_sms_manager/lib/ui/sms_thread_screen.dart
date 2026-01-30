import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/sms_thread_controller.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';
import 'package:smart_call_sms_manager/data/database_helper.dart';

class SmsThreadScreen extends StatelessWidget {
  final String address;
  final String? threadId; // New parameter
  final String? name;
  final Function? onMessagesRead;

  const SmsThreadScreen({super.key, required this.address, this.threadId, this.name, this.onMessagesRead});

  Future<void> _schedule(BuildContext context, SmsThreadController controller, String msg) async {
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
    
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    
    final scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    
    await DatabaseHelper().addSchedule(address, msg, scheduledAt);
    await NativeService.scheduleSms(address, msg, scheduledAt);
    
    Get.snackbar('Success', 'Message scheduled!');
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SmsThreadController(
      address: address, 
      threadId: threadId, 
      initialName: name, 
      onMessagesRead: onMessagesRead
    ));
    final textController = TextEditingController();
    
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.contactName ?? address),
            if (controller.contactName != null) 
              Text(address, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        )),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () => NativeService.makeDirectCall(address)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => controller.isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : ListView.builder(
                  itemCount: controller.messages.length,
                  reverse: false, 
                  controller: ScrollController(initialScrollOffset: 10000), 
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    final isMe = msg['type'] == '2'; 
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg['body'] ?? '',
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                )
            ),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onLongPress: () => _schedule(context, controller, textController.text),
                  onTap: () async {
                    await controller.sendMessage(textController.text);
                    textController.clear();
                  },
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
