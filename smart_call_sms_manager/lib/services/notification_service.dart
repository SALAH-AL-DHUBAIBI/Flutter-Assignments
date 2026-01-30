import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showReminder({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'schedule_reminder_channel',
      'Scheduled Reminders',
      channelDescription: 'Reminders for scheduled SMS',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  static Future<void> showNewMessageNotification({
    required int id,
    required String senderName,
    required String message,
    String? number,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'new_message_channel',
      'New Messages',
      channelDescription: 'Notifications for new incoming messages',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      colorized: true,
      color: Colors.blue,
      ticker: 'New message received',
      styleInformation: BigTextStyleInformation(''),
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      'New message from $senderName',
      message,
      platformChannelSpecifics,
      payload: payload ?? number,
    );
  }

  static Future<void> showMissedCallNotification({
    required int id,
    required String callerName,
    required String number,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'missed_call_channel',
      'Missed Calls',
      channelDescription: 'Notifications for missed calls',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      colorized: true,
      color: Colors.red,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id,
      'Missed call',
      'From: $callerName ($number)',
      platformChannelSpecifics,
      payload: payload ?? number,
    );
  }
}