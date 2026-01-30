import 'package:get/get.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsController extends GetxController {
  
  Future<void> requestDefaultDialerRole() async {
    await NativeService.requestDefaultDialerRole();
  }
  
  Future<void> requestDefaultSmsRole() async {
    await NativeService.requestDefaultSmsRole();
  }
  
  Future<void> requestAllPermissions() async {
    await [
      Permission.phone,
      Permission.sms,
      Permission.contacts,
      Permission.notification,
    ].request();
  }
}
