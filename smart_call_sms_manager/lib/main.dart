import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/services/notification_service.dart';
import 'package:smart_call_sms_manager/services/contact_cache_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_call_sms_manager/ui/home_screen.dart';
import 'package:smart_call_sms_manager/themes.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await GetStorage.init();
  await NotificationService.initialize();
  
  Get.put(ContactCacheService());
  
  runApp(const SmartManagerSafeApp());
}

class SmartManagerSafeApp extends StatelessWidget {
  const SmartManagerSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final bool isDark = box.read('isDark') == true;

    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: Colors.black,
              systemNavigationBarIconBrightness: Brightness.light,
            )
          : const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
    );

    return GetMaterialApp(
      title: 'Smart Manager',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}