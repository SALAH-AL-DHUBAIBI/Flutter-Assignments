import 'package:get/get.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';


class SmsComposeController extends GetxController {
  final _number = ''.obs;
  final _message = ''.obs;
  
  String get number => _number.value;
  String get message => _message.value;
  
  void setNumber(String value) => _number.value = value;
  void setMessage(String value) => _message.value = value;
  
  Future<void> sendMessage() async {
    if (_number.value.isEmpty) return;
    
    try {
      await NativeService.sendDirectSms(_number.value, _message.value);

      
      Get.snackbar('Success', 'Message sent!');
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send: $e');
    }
  }
}
