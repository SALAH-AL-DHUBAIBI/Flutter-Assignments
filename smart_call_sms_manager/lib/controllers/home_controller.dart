import 'package:get/get.dart';

class HomeController extends GetxController {
  final _selectedIndex = 0.obs;
  
  int get selectedIndex => _selectedIndex.value;
  
  void changeTab(int index) {
    _selectedIndex.value = index;
  }
  
  @override
  void onInit() {
    super.onInit();
    // Check defaults on initialization
    _checkDefaults();
  }
  
  Future<void> _checkDefaults() async {
    // In a real app we would check RoleManager.isRoleHeld. 
    // For now, we just rely on user action in Settings or NativeService prompts.
  }
}
