import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';
import 'package:smart_call_sms_manager/services/contact_cache_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class SmsController extends GetxController {
  final _messages = <Map<dynamic, dynamic>>[].obs;
  final _isLoading = true.obs;
  final _isLoadingMore = false.obs;
  final _hasMore = true.obs;
  final _page = 0.obs;
  final _pageSize = 20.obs;
  final _newMessagesCount = 0.obs;
  
  // For debouncing
  Timer? _refreshTimer;

  List<Map<dynamic, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMore => _hasMore.value;
  int get newMessagesCount => _newMessagesCount.value;

  @override
  void onInit() {
    super.onInit();
    fetchSms();
    _setupAutoRefresh();
  }

  @override
  void onClose() {
    _refreshTimer?.cancel();
    super.onClose();
  }

  void _setupAutoRefresh() {
    // تحديث تلقائي كل 30 ثانية
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isLoading.value) {
        _checkForNewMessages();
      }
    });
  }

  Future<void> _checkForNewMessages() async {
    try {
      if (await Permission.sms.request().isGranted) {
        final allThreads = await NativeService.getSmsConversations();
        final newCount = _countNewMessages(allThreads);
        
        if (newCount > _newMessagesCount.value) {
          _newMessagesCount.value = newCount;
          // يمكن إضافة إشعار هنا
          _triggerNewMessageNotification();
        }
      }
    } catch (e) {
      debugPrint('Error checking for new messages: $e');
    }
  }

  int _countNewMessages(List<Map<String, dynamic>> threads) {
    int count = 0;
    for (final thread in threads) {
      final unreadCount = int.tryParse(thread['unread_count'] ?? '0') ?? 0;
      count += unreadCount;
    }
    return count;
  }

  void _triggerNewMessageNotification() {
    // سيتم تنفيذ هذا في الخطوة التالية
  }

  Future<void> fetchSms({bool silent = false, bool loadMore = false}) async {
    if (loadMore) {
      _isLoadingMore.value = true;
    } else if (!silent) {
      _isLoading.value = true;
      _page.value = 0;
      _hasMore.value = true;
    }

    if (await Permission.sms.request().isGranted) {
      try {
        final threads = await NativeService.getSmsConversations();
        
        // Update new messages count
        _newMessagesCount.value = _countNewMessages(threads);

        final startIndex = _page.value * _pageSize.value;
        final endIndex = startIndex + _pageSize.value;

        if (startIndex >= threads.length) {
          _hasMore.value = false;
          _isLoadingMore.value = false;
          return;
        }

        final currentPageThreads = threads.sublist(
          startIndex,
          endIndex < threads.length ? endIndex : threads.length,
        );

        // تحسين الأداء: معالجة الأسماء بشكل مجمع
        await _processContactNames(currentPageThreads);

        if (loadMore) {
          _messages.addAll(currentPageThreads);
        } else {
          _messages.value = currentPageThreads;
        }

        _page.value++;
        _hasMore.value = endIndex < threads.length;
      } catch (e) {
        debugPrint('Error fetching SMS: $e');
        Get.snackbar('Error', 'Failed to load messages: $e');
      }
    }

    _isLoading.value = false;
    _isLoadingMore.value = false;
  }

  Future<void> _processContactNames(List<Map<dynamic, dynamic>> threads) async {
    final cache = ContactCacheService.to;
    final List<String> numbersToFetch = [];
    
    // أولاً: استرجاع ما هو موجود في الكاش
    for (var thread in threads) {
      final address = thread['address'];
      if (address != null) {
        final cachedName = cache.getContactName(address);
        if (cachedName != null) {
          thread['name'] = cachedName;
        } else {
          numbersToFetch.add(address);
        }
      }
    }
    
    // ثانياً: جلب الأسماء المفقودة من الخدمة الأصلية
    if (numbersToFetch.isNotEmpty) {
      await _fetchMissingNames(numbersToFetch, threads, cache);
    }
  }

  Future<void> _fetchMissingNames(
    List<String> numbers, 
    List<Map<dynamic, dynamic>> threads,
    ContactCacheService cache
  ) async {
    for (final number in numbers) {
      try {
        final name = await NativeService.getContactName(number);
        if (name != null) {
          cache.setContactName(number, name);
          // تحديث الـ threads المناسبة
          for (var thread in threads) {
            if (thread['address'] == number) {
              thread['name'] = name;
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching name for $number: $e');
      }
    }
  }

  Future<void> loadMore() async {
    if (_hasMore.value && !_isLoadingMore.value && !_isLoading.value) {
      await fetchSms(silent: true, loadMore: true);
    }
  }

  void updateThread(String threadId, Map<String, dynamic> updates) {
    final index = _messages.indexWhere(
      (thread) => thread['thread_id'] == threadId,
    );
    if (index != -1) {
      final updatedThread = {..._messages[index], ...updates};
      _messages[index] = updatedThread;
      _messages.refresh();
    }
  }

  // احتفظ بهذه الدالة للتوافق مع الأكواد الأخرى
  String formatDate(String? timestampStr) {
    if (timestampStr == null) return "";
    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return "";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM d').format(date);
  }

  Future<void> refreshSms() async {
    _page.value = 0;
    _hasMore.value = true;
    _messages.clear();
    await fetchSms();
  }
}