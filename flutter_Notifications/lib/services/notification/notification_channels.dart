import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChannels {
  static const AndroidNotificationDetails taskChannel =
      AndroidNotificationDetails(
    'task_channel',
    'Task Notifications',
    channelDescription: 'Notifications related to tasks',
    importance: Importance.high,
    priority: Priority.high,
  );
}
