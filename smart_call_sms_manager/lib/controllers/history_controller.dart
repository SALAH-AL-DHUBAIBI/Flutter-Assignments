import 'package:get/get.dart';
import 'package:smart_call_sms_manager/services/native_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class HistoryController extends GetxController {
  final _logs = <Map<dynamic, dynamic>>[].obs;
  final _isLoading = true.obs;
  final _groupedLogs = <Map<String, dynamic>>[].obs;
  
  // Cache for processed groups
  final Map<String, Map<String, dynamic>> _groupsCache = {};

  List<Map<dynamic, dynamic>> get logs => _logs;
  bool get isLoading => _isLoading.value;
  List<Map<String, dynamic>> get groupedLogs => _groupedLogs;

  @override
  void onInit() {
    super.onInit();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    _isLoading.value = true;
    _groupsCache.clear();

    if (await Permission.phone.request().isGranted &&
        await Permission.contacts.request().isGranted) {
      try {
        final logs = await NativeService.getCallLogs();
        _logs.value = logs;
        _processGrouping();
      } catch (e) {
        Get.snackbar('Error', 'Failed to load call logs: $e');
      }
    }

    _isLoading.value = false;
  }

  void _processGrouping() {
    // Sort logs by date descending first to ensure consistent processing
    _logs.sort((a, b) {
      final dateA = int.tryParse(a['date']?.toString() ?? '0') ?? 0;
      final dateB = int.tryParse(b['date']?.toString() ?? '0') ?? 0;
      return dateB.compareTo(dateA); // Newest first
    });

    final Map<String, Map<String, dynamic>> groupsMap = {};
    
    for (final entry in _logs) {
      final number = entry['number']?.toString() ?? '';
      if (number.isEmpty) continue;
      
      final duration = int.tryParse((entry['duration'] ?? '0').toString()) ?? 0;
      final name = entry['name'];
      final type = entry['type'];
      final date = entry['date'];

      if (!groupsMap.containsKey(number)) {
        groupsMap[number] = {
          'number': number,
          'name': name,
          'type': type,
          'count': 1,
          'totalDuration': duration,
          'date': date, // This will be the newest date because of the sort above
          'lastCallType': type,
        };
      } else {
        final group = groupsMap[number]!;
        group['count'] = (group['count'] as int) + 1;
        group['totalDuration'] = (group['totalDuration'] as int) + duration;
        // Do NOT overwrite date, as we processing newest first, so the first one we saw is the latest.
      }
    }

    final sortedGroups = groupsMap.values.toList(); 
    // They are already roughly sorted by insertion order if the map preserves it, 
    // but a list sort ensures it.
    sortedGroups.sort((a, b) {
        final dateA = int.tryParse(a['date']?.toString() ?? '0') ?? 0;
        final dateB = int.tryParse(b['date']?.toString() ?? '0') ?? 0;
        return dateB.compareTo(dateA);
    });

    _groupedLogs.value = sortedGroups;
    _groupsCache.addAll(groupsMap);
  }

  List<Map<dynamic, dynamic>> getLogsForNumber(String number) {
    // استخدام cache للبحث بشكل أسرع
    if (_groupsCache.containsKey(number)) {
      return _logs.where((l) => (l['number']?.toString() ?? '') == number).toList();
    }
    
    // البحث الخطي فقط إذا لم يكن في cache
    return _logs.where((l) => (l['number']?.toString() ?? '') == number).toList();
  }

  String formatDate(String? timestampStr) {
    if (timestampStr == null) return "";
    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return "";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM d, h:mm a').format(date);
  }

  Future<void> refreshLogs() async {
    await fetchLogs();
  }
}