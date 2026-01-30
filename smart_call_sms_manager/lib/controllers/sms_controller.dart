import 'package:get/get.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class SmsController extends GetxController {
  final _messages = <Map<dynamic, dynamic>>[].obs;
  final _isLoading = true.obs;
  
  List<Map<dynamic, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    fetchSms();
  }
  
  Future<void> fetchSms({bool silent = false}) async {
    if (!silent) _isLoading.value = true;
    
    if (await Permission.sms.request().isGranted) {
      // Get SMS conversations
      final threads = await NativeService.getSmsConversations();
      
      // Resolve contact names for first 20 threads
      // Note: In a real app we'd page this or resolve on demand
      for (var i = 0; i < threads.length && i < 20; i++) {
        final address = threads[i]['address'];
        if (address != null) {
          final name = await NativeService.getContactName(address);
          if (name != null) {
            threads[i]['name'] = name;
          }
        }
      }
      
      _messages.value = threads;
    }
    
    if (!silent) _isLoading.value = false;
  }
  
  String formatDate(String? timestampStr) {
    if (timestampStr == null) return "";
    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return "";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM d').format(date);
  }
}
