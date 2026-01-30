import 'package:get/get.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';

class DialerController extends GetxController {
  final _number = ''.obs;
  final _contactName = Rxn<String>();
  
  String get number => _number.value;
  String? get contactName => _contactName.value;
  
  void onKeyPress(String val) {
    _number.value += val;
    _lookupName();
  }
  
  void onBackspace() {
    if (_number.value.isNotEmpty) {
      _number.value = _number.value.substring(0, _number.value.length - 1);
      _lookupName();
    }
  }
  
  void onLongBackspace() {
    _number.value = '';
    _contactName.value = null;
  }
  
  Future<void> _lookupName() async {
    if (_number.value.length > 2) {
      final name = await NativeService.getContactName(_number.value);
      _contactName.value = name;
    } else {
      _contactName.value = null;
    }
  }
  
  Future<void> makeCall() async {
    if (_number.value.isNotEmpty) {
      await NativeService.makeDirectCall(_number.value);
      // Clear number and name after call
      _number.value = '';
      _contactName.value = null;
    }
  }
}
