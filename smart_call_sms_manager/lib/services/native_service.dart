import 'package:flutter/services.dart';

class NativeService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.smart_manager/native',
  );

  static Future<String?> getContactName(String number) async {
    try {
      final String? name = await _channel.invokeMethod('getContactName', {
        'number': number,
      });
      return name;
    } on PlatformException {
      return null;
    }
  }

  static Future<bool> requestDefaultDialerRole() async {
    try {
      final bool? result = await _channel.invokeMethod(
        'requestDefaultDialerRole',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> requestDefaultSmsRole() async {
    try {
      final bool? result = await _channel.invokeMethod('requestDefaultSmsRole');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> makeDirectCall(String number) async {
    try {
      await _channel.invokeMethod('makeDirectCall', {'number': number});
    } on PlatformException catch (e) {
      throw "Failed to call: ${e.message}";
    }
  }

  static Future<void> sendDirectSms(String number, String message) async {
    try {
      await _channel.invokeMethod('sendDirectSms', {
        'number': number,
        'message': message,
      });
    } on PlatformException catch (e) {
      throw "Failed to send SMS: ${e.message}";
    }
  }

  static Future<List<Map<String, dynamic>>> getCallLogs() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod('getCallLogs');
      return result
              ?.cast<Map<dynamic, dynamic>>()
              .map((e) => e.cast<String, dynamic>())
              .toList() ??
          [];
    } on PlatformException {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getSmsConversations() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod(
        'getSmsConversations',
      );
      return result
              ?.cast<Map<dynamic, dynamic>>()
              .map((e) => e.cast<String, dynamic>())
              .toList() ??
          [];
    } on PlatformException {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getSmsMessages(
    String address,
  ) async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod(
        'getSmsMessages',
        {'address': address},
      );
      return result
              ?.cast<Map<dynamic, dynamic>>()
              .map((e) => e.cast<String, dynamic>())
              .toList() ??
          [];
    } on PlatformException {
      return [];
    }
  }

  static Future<void> scheduleSms(
    String number,
    String message,
    DateTime time,
  ) async {
    try {
      await _channel.invokeMethod('scheduleSms', {
        'number': number,
        'message': message,
        'time': time.millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      throw "Failed to schedule: ${e.message}";
    }
  }

  static Future<void> markMessagesAsRead(String threadId) async {
    try {
      await _channel.invokeMethod('markMessagesAsRead', {'threadId': threadId});
    } on PlatformException catch (e) {
      throw "Failed to mark as read: ${e.message}";
    }
  }
}