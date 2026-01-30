import 'package:get/get.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class HistoryController extends GetxController {
  final _logs = <Map<dynamic, dynamic>>[].obs;
  final _isLoading = true.obs;
  
  List<Map<dynamic, dynamic>> get logs => _logs;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    fetchLogs();
  }
  
  Future<void> fetchLogs() async {
    _isLoading.value = true;
    
    // Request permissions
    if (await Permission.phone.request().isGranted && 
        await Permission.contacts.request().isGranted) {
      final logs = await NativeService.getCallLogs();
      _logs.value = logs;
    }
    
    _isLoading.value = false;
  }
  
  String formatDate(String? timestampStr) {
    if (timestampStr == null) return "";
    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return "";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM d, h:mm a').format(date);
  }
}
