import 'package:get/get.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';

class SmsThreadController extends GetxController {
  final String address;
  final String? threadId; // New field
  final String? initialName;
  final Function? onMessagesRead; 
  
  final _messages = <Map<dynamic, dynamic>>[].obs;
  final _isLoading = true.obs;
  final _contactName = Rxn<String>();
  
  SmsThreadController({required this.address, this.threadId, this.initialName, this.onMessagesRead});
  
  List<Map<dynamic, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading.value;
  String? get contactName => _contactName.value;
  
  @override
  void onInit() {
    super.onInit();
    _contactName.value = initialName;
    loadData();
    _markAsReadAsync();
  }
  
  Future<void> _markAsReadAsync() async {
    // Mark messages as read when conversation is opened
    try {
      if (threadId != null) {
        await NativeService.markMessagesAsRead(threadId!);
      } else {
        // Fallback or leave as is if threadId is missing (shouldn't happen)
      }
      
      // Notify parent to refresh list
      if (onMessagesRead != null) {
        onMessagesRead!();
      }
    } catch (e) {
      // Silently handle error
    }
  }
  
  Future<void> loadData() async {
    // If name wasn't passed, try looking it up
    if (_contactName.value == null) {
      final name = await NativeService.getContactName(address);
      if (name != null) _contactName.value = name;
    }
    
    // Load messages
    final msgs = await NativeService.getSmsMessages(address);
    _messages.value = msgs;
    _isLoading.value = false;
  }
  
  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
    
    try {
      await NativeService.sendDirectSms(address, text);
      
      // Optimistic update or refresh
      await Future.delayed(const Duration(seconds: 1));
      await loadData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message: $e');
    }
  }
}
