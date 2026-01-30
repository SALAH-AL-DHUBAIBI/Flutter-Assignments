import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';
import 'package:smart_call_sms_manager/services/contact_cache_service.dart';

class SmsThreadController extends GetxController {
  final String address;
  final String? threadId;
  final String? initialName;
  final Function? onMessagesRead;

  final _messages = <Map<dynamic, dynamic>>[].obs;
  final _isLoading = true.obs;
  final _isSending = false.obs;
  final _contactName = Rxn<String>();

  SmsThreadController({
    required this.address,
    this.threadId,
    this.initialName,
    this.onMessagesRead,
  });

  List<Map<dynamic, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isSending => _isSending.value;
  String? get contactName => _contactName.value;

  @override
  void onInit() {
    super.onInit();
    _contactName.value = initialName;
    loadData();
    _markAsReadAsync();
  }

  Future<void> _markAsReadAsync() async {
    try {
      if (threadId != null) {
        await NativeService.markMessagesAsRead(threadId!);
      }

      if (onMessagesRead != null) {
        onMessagesRead!();
      }
    } catch (e) {
      // Log error silently
      debugPrint('Error marking messages as read: $e');
    }
  }

  Future<void> loadData() async {
    if (_contactName.value == null) {
      final cachedName = ContactCacheService.to.getContactName(address);
      if (cachedName != null) {
        _contactName.value = cachedName;
      } else {
        final name = await NativeService.getContactName(address);
        if (name != null) {
          ContactCacheService.to.setContactName(address, name);
          _contactName.value = name;
        }
      }
    }

    final msgs = await NativeService.getSmsMessages(address);
    _messages.value = msgs;
    _isLoading.value = false;
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    _isSending.value = true;
    try {
      await NativeService.sendDirectSms(address, text);

      // إضافة رسالة محلية فوراً (Optimistic Update)
      final newMessage = {
        'body': text,
        'type': '2', // Outgoing
        'date': DateTime.now().millisecondsSinceEpoch.toString(),
        'address': address,
      };
      
      _messages.insert(0, newMessage);
      _messages.refresh();

      // تحديث البيانات بعد ثانية للتأكد من المزامنة
      await Future.delayed(const Duration(seconds: 1));
      await loadData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    } finally {
      _isSending.value = false;
    }
  }

  Future<void> refreshMessages() async {
    _isLoading.value = true;
    await loadData();
  }
}