import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsController extends GetxController {
  final _isDark = RxBool(Get.isDarkMode);

  bool get isDark => _isDark.value;

  void toggleTheme([bool? value]) {
    final newVal = value ?? !_isDark.value;
    if (newVal) {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
    _isDark.value = newVal;
    // persist
    final box = GetStorage();
    box.write('isDark', newVal);
    // update system UI overlay to match theme immediately
    SystemChrome.setSystemUIOverlayStyle(
      newVal
          ? const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
            )
          : const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
            ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    final box = GetStorage();
    final val = box.read('isDark');
    if (val != null && val is bool) {
      _isDark.value = val;
      // ensure Get theme matches stored value
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
      });
      SystemChrome.setSystemUIOverlayStyle(
        val
            ? const SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.light,
              )
            : const SystemUiOverlayStyle(
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.dark,
              ),
      );
    }
  }

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
