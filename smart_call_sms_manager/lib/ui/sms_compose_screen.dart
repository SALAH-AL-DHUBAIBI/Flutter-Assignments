import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/sms_compose_controller.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';
import 'package:smart_call_sms_manager/data/database_helper.dart';

class SmsComposeScreen extends StatelessWidget {
  const SmsComposeScreen({super.key});

  Future<void> _schedule(BuildContext context, String number, String msg) async {
    if (number.isEmpty) return;

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
    
    await DatabaseHelper().addSchedule(number, msg, scheduledAt);
    await NativeService.scheduleSms(number, msg, scheduledAt);
    
    Get.snackbar('Success', 'Message scheduled!');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SmsComposeController());
    final numberController = TextEditingController();
    final msgController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Message"),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm_add), 
            onPressed: () => _schedule(context, numberController.text, msgController.text)
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: "To",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                onChanged: controller.setNumber,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      decoration: const InputDecoration(
                        hintText: "Text message",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16)
                      ),
                      minLines: 1,
                      maxLines: 5,
                      onChanged: controller.setMessage,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
                    onPressed: controller.sendMessage,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
