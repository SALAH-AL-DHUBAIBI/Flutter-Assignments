import 'dart:async';
import 'package:get/get.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';
import 'package:smart_call_sms_manager/services/contact_cache_service.dart';

class DialerController extends GetxController {
  final _number = ''.obs;
  final _contactName = Rxn<String>();
  
  // For debouncing
  Timer? _lookupTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  String get number => _number.value;
  String? get contactName => _contactName.value;

  void onKeyPress(String val) {
    _number.value += val;
    _scheduleLookup();
  }

  void onBackspace() {
    if (_number.value.isNotEmpty) {
      _number.value = _number.value.substring(0, _number.value.length - 1);
      _scheduleLookup();
    }
  }

  void onLongBackspace() {
    _number.value = '';
    _contactName.value = null;
    _lookupTimer?.cancel();
  }

  void _scheduleLookup() {
    _lookupTimer?.cancel();
    _lookupTimer = Timer(_debounceDelay, _performLookup);
  }

  Future<void> _performLookup() async {
    if (_number.value.length > 2) {
      // أولاً: تحقق من التخزين المؤقت
      final cachedName = ContactCacheService.to.getContactName(_number.value);
      if (cachedName != null) {
        _contactName.value = cachedName;
        return;
      }
      
      // ثانياً: جلب الاسم من الخدمة الأصلية
      final name = await NativeService.getContactName(_number.value);
      _contactName.value = name;
      
      // حفظ في التخزين المؤقت
      if (name != null) {
        ContactCacheService.to.setContactName(_number.value, name);
      }
    } else {
      _contactName.value = null;
    }
  }

  Future<void> makeCall() async {
    if (_number.value.isNotEmpty) {
      await NativeService.makeDirectCall(_number.value);
      _number.value = '';
      _contactName.value = null;
      _lookupTimer?.cancel();
    }
  }

  @override
  void onClose() {
    _lookupTimer?.cancel();
    super.onClose();
  }
}