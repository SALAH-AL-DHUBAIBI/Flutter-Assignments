import 'package:get/get.dart';
import 'package:smart_call_sms_manager/controllers/history_controller.dart';

class HomeController extends GetxController {
  final _selectedIndex = 0.obs;

  int get selectedIndex => _selectedIndex.value;

  void changeTab(int index) {
    _selectedIndex.value = index;
    if (index == 2) {
      try {
        final hc = Get.find<HistoryController>();
        hc.fetchLogs();
      } catch (e) {
        Get.put(HistoryController());
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    _checkDefaults();
  }

  Future<void> _checkDefaults() async {
  }
}
