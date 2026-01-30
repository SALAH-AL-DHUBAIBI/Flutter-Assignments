import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ContactCacheService extends GetxService {
  static ContactCacheService get to => Get.find();
  
  final GetStorage _storage = GetStorage();
  final Map<String, String> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  static const String _cacheKey = 'contact_cache';
  static const Duration _cacheDuration = Duration(hours: 24);
  
  @override
  Future<void> onInit() async {
    await _loadCacheFromStorage();
    super.onInit();
  }
  
  Future<void> _loadCacheFromStorage() async {
    final cachedData = _storage.read<Map<String, dynamic>>(_cacheKey);
    if (cachedData != null) {
      _memoryCache.addAll(Map<String, String>.from(cachedData));
    }
  }
  
  Future<void> _saveCacheToStorage() async {
    await _storage.write(_cacheKey, _memoryCache);
  }
  
  String? getContactName(String number) {
    final cachedName = _memoryCache[number];
    final timestamp = _cacheTimestamps[number];
    
    if (cachedName != null && timestamp != null) {
      final age = DateTime.now().difference(timestamp);
      if (age <= _cacheDuration) {
        return cachedName;
      } else {
        // Cache expired
        _memoryCache.remove(number);
        _cacheTimestamps.remove(number);
      }
    }
    return null;
  }
  
  void setContactName(String number, String name) {
    _memoryCache[number] = name;
    _cacheTimestamps[number] = DateTime.now();
    _saveCacheToStorage(); // Save async
  }
  
  void clearCache() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    _storage.remove(_cacheKey);
  }

}